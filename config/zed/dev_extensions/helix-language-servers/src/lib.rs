use serde::{Deserialize, Serialize};
use std::collections::{hash_map::Entry, HashMap};
use toml;
use zed_extension_api::{self as zed, Command, LanguageServerId, Result, Worktree};

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub struct Configuration {
    #[serde(default)]
    pub language_server: HashMap<String, LanguageServerConfiguration>,
}

fn default_timeout() -> u64 {
    20
}

fn deserialize_lsp_config<'de, D>(deserializer: D) -> Result<Option<serde_json::Value>, D::Error>
where
    D: serde::Deserializer<'de>,
{
    Option::<toml::Value>::deserialize(deserializer)?
        .map(|toml| toml.try_into().map_err(serde::de::Error::custom))
        .transpose()
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub struct LanguageServerConfiguration {
    pub command: String,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub args: Vec<String>,
    #[serde(default, skip_serializing_if = "HashMap::is_empty")]
    pub environment: HashMap<String, String>,
    #[serde(default, skip_serializing, deserialize_with = "deserialize_lsp_config")]
    pub config: Option<serde_json::Value>,
    #[serde(default = "default_timeout")]
    pub timeout: u64,
    // #[serde(default)]
    // pub required_root_patterns: Option<GlobSet>,
}

/// Servers this extension provides, transcribed from the user's Helix
/// `languages.toml`.
///
/// These values cannot be read at runtime: an extension is a WASM guest whose
/// only filesystem access is `Worktree::read_text_file`, which is confined to
/// the project root, so the global `~/.config/helix/languages.toml` is out of
/// reach. They are baked in instead.
const LANGUAGES_TOML: &str = r#"
[language-server.prettier-lsp]
command = "prettier-lsp"
args = ["--stdio"]

[language-server.prettier-lsp.config.prettierLsp]
localOnly = true

[language-server.gitattributes-lsp]
command = "gitattributes-lsp"
args = ["--stdio"]

[language-server.gitconfig-lsp]
command = "gitconfig-lsp"
args = ["--stdio"]

[language-server.nxls]
command = "nxls"
args = ["--stdio"]

[language-server.oxvg]
command = "oxvg"
args = ["lint", "serve"]

[language-server.cci-yaml]
command = "/Users/emily.klassen/Library/Application Support/CircleCI-language-server/circleci-yaml-language-server"
args = ["-schema=/Users/emily.klassen/Library/Application Support/CircleCI-language-server/schema.json", "--stdio"]
"#;

struct HelixLanguageServersExtension {
    default_config: Configuration,
    worktree_config: HashMap<u64, Configuration>,
}

pub fn merge_toml_values(left: toml::Value, right: toml::Value, merge_depth: usize) -> toml::Value {
    use toml::Value;

    fn get_name(v: &Value) -> Option<&str> {
        v.get("name").and_then(Value::as_str)
    }

    match (left, right) {
        (Value::Array(mut left_items), Value::Array(right_items)) => {
            if merge_depth > 0 {
                left_items.reserve(right_items.len());
                for rvalue in right_items {
                    let lvalue = get_name(&rvalue)
                        .and_then(|rname| {
                            left_items.iter().position(|v| get_name(v) == Some(rname))
                        })
                        .map(|lpos| left_items.remove(lpos));
                    let mvalue = match lvalue {
                        Some(lvalue) => merge_toml_values(lvalue, rvalue, merge_depth - 1),
                        None => rvalue,
                    };
                    left_items.push(mvalue);
                }
                Value::Array(left_items)
            } else {
                Value::Array(right_items)
            }
        }
        (Value::Table(mut left_map), Value::Table(right_map)) => {
            if merge_depth > 0 {
                for (rname, rvalue) in right_map {
                    match left_map.remove(&rname) {
                        Some(lvalue) => {
                            let merged_value = merge_toml_values(lvalue, rvalue, merge_depth - 1);
                            left_map.insert(rname, merged_value);
                        }
                        None => {
                            left_map.insert(rname, rvalue);
                        }
                    }
                }
                Value::Table(left_map)
            } else {
                Value::Table(right_map)
            }
        }
        // Catch everything else we didn't handle, and use the right value
        (_, value) => value,
    }
}

fn read_worktree_config(worktree: &Worktree) -> Result<toml::Value, String> {
    let config_str = worktree.read_text_file(".helix/languages.toml")?;
    match toml::from_str(&config_str) {
        Ok(config) => Ok(config),
        Err(err) => Err(err.message().to_string()),
    }
}

impl HelixLanguageServersExtension {
    fn get_config(&mut self, worktree: &Worktree) -> &Configuration {
        match self.worktree_config.entry(worktree.id()) {
            Entry::Occupied(e) => e.into_mut(),
            Entry::Vacant(e) => match read_worktree_config(worktree) {
                Ok(worktree_config) => {
                    let config: Result<Configuration, _> = merge_toml_values(
                        toml::from_str(&LANGUAGES_TOML).unwrap(),
                        worktree_config,
                        3,
                    )
                    .try_into();
                    match config {
                        Ok(config) => e.insert(config),
                        _ => &self.default_config,
                    }
                }
                _ => &self.default_config,
            },
        }
    }
}

impl zed::Extension for HelixLanguageServersExtension {
    fn new() -> Self {
        Self {
            default_config: toml::from_str(LANGUAGES_TOML).expect("Could not parse built-in toml"),
            worktree_config: HashMap::new(),
        }
    }

    fn language_server_command(
        &mut self,
        language_server_id: &LanguageServerId,
        worktree: &Worktree,
    ) -> Result<Command> {
        let id = language_server_id.as_ref();
        let spec = self
            .get_config(worktree)
            .language_server
            .get(id)
            .ok_or_else(|| format!("`{id}` is not provided by this extension"))?;

        let command = if spec.command.starts_with("/") {
            spec.command.clone()
        } else if let Some(path) = worktree.which(&spec.command) {
            path
        } else {
            return Err(format!(
                "`{}` was not found on $PATH. Install it, or point Zed at it with the \
                         `lsp.{}.binary.path` setting.",
                spec.command, id
            ));
        };

        Ok(Command {
            command,
            args: spec.args.iter().map(|arg| (*arg).to_string()).collect(),
            env: Vec::new(),
        })
    }

    /// Mirrors `[language-server.<id>.config]`, which Helix sends as LSP
    /// initialization options.
    fn language_server_initialization_options(
        &mut self,
        language_server_id: &LanguageServerId,
        worktree: &Worktree,
    ) -> Result<Option<serde_json::Value>> {
        let id = language_server_id.as_ref();
        let spec = self
            .get_config(worktree)
            .language_server
            .get(id)
            .ok_or_else(|| format!("`{id}` is not provided by this extension"))?;
        Ok(spec.config.clone())
    }
}

zed::register_extension!(HelixLanguageServersExtension);
