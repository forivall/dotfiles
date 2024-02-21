// nx

export type ProjectType = 'library' | 'application'
export interface ProjectConfiguration {
  /**
   * Project's name. Optional if specified in workspace.json
   */
  name?: string
  /**
   * Project's targets
   */
  targets?: {
    [targetName: string]: TargetConfiguration
  }
  /**
   * Project's location relative to the root of the workspace
   */
  root: string
  /**
   * The location of project's sources relative to the root of the workspace
   */
  sourceRoot?: string
  /**
   * Project type
   */
  projectType?: ProjectType
  /**
   * List of default values used by generators.
   *
   * These defaults are project specific.
   *
   * Example:
   *
   * ```
   * {
   *   "@nx/react": {
   *     "library": {
   *       "style": "scss"
   *     }
   *   }
   * }
   * ```
   */
  generators?: {
    [collectionName: string]: {
      [generatorName: string]: any
    }
  }
  /**
   * List of projects which are added as a dependency
   */
  implicitDependencies?: string[]
  /**
   * Named inputs targets can refer to reduce duplication
   */
  namedInputs?: {
    [inputName: string]: (string | InputDefinition)[]
  }
  /**
   * List of tags used by enforce-module-boundaries / project graph
   */
  tags?: string[]
}
export interface TargetDependencyConfig {
  /**
   * A list of projects that have `target`.
   * Should not be specified together with `dependencies`.
   */
  projects?: string[] | string
  /**
   * If true, the target will be executed for each project that this project depends on.
   * Should not be specified together with `projects`.
   */
  dependencies?: boolean
  /**
   * The name of the target to run. If `projects` and `dependencies` are not specified,
   * the target will be executed for the same project the the current target is running on`.
   */
  target: string
  /**
   * Configuration for params handling.
   */
  params?: 'ignore' | 'forward'
}
export type InputDefinition =
  | {
      input: string
      projects: string | string[]
    }
  | {
      input: string
      dependencies: true
    }
  | {
      input: string
    }
  | {
      fileset: string
    }
  | {
      runtime: string
    }
  | {
      externalDependencies: string[]
    }
  | {
      dependentTasksOutputFiles: string
      transitive?: boolean
    }
  | {
      env: string
    }
export interface TargetConfiguration<T = any> {
  /**
   * The executor/builder used to implement the target.
   *
   * Example: '@nx/rollup:rollup'
   */
  executor?: string
  /**
   * Used as a shorthand for nx:run-commands, a command to run.
   */
  command?: string
  /**
   * List of the target's outputs. The outputs will be cached by the Nx computation
   * caching engine.
   */
  outputs?: string[]
  /**
   * This describes other targets that a target depends on.
   */
  dependsOn?: (TargetDependencyConfig | string)[]
  /**
   * This describes filesets, runtime dependencies and other inputs that a target depends on.
   */
  inputs?: (InputDefinition | string)[]
  /**
   * Target's options. They are passed in to the executor.
   */
  options?: T
  /**
   * Sets of options
   */
  configurations?: {
    [config: string]: any
  }
  /**
   * A default named configuration to use when a target configuration is not provided.
   */
  defaultConfiguration?: string
  /**
   * Determines if Nx is able to cache a given target.
   */
  cache?: boolean
}

// typescript

export enum DiagnosticCategory {
  Warning,
  Error,
  Suggestion,
  Message,
}

export interface DiagnosticMessage {
  key: string
  category: DiagnosticCategory
  code: number
  message: string
  reportsUnnecessary?: {}
  reportsDeprecated?: {}
  /** @internal */
  elidedInCompatabilityPyramid?: boolean
}

// dprint-ignore
/** @internal */
export interface CommandLineOptionBase {
  name: string
  type:
    | 'string'
    | 'number'
    | 'boolean'
    | 'object'
    | 'list'
    | 'listOrElement'
    | Map<string, number | string> // a value of a primitive type, or an object literal mapping named values to actual values
  isFilePath?: boolean // True if option value is a path or fileName
  shortName?: string // A short mnemonic for convenience - for instance, 'h' can be used in place of 'help'
  description?: DiagnosticMessage // The message describing what the command line switch does.
  defaultValueDescription?:
    | string
    | number
    | boolean
    | DiagnosticMessage
    | undefined // The message describing what the dafault value is. string type is prepared for fixed chosen like "false" which do not need I18n.
  paramType?: DiagnosticMessage // The name to be used for a non-boolean option's parameter
  isTSConfigOnly?: boolean // True if option can only be specified via tsconfig.json file
  isCommandLineOnly?: boolean
  showInSimplifiedHelpView?: boolean
  category?: DiagnosticMessage
  strictFlag?: true // true if the option is one of the flag under strict
  allowJsFlag?: true
  affectsSourceFile?: true // true if we should recreate SourceFiles after this option changes
  affectsModuleResolution?: true // currently same effect as `affectsSourceFile`
  affectsBindDiagnostics?: true // true if this affects binding (currently same effect as `affectsSourceFile`)
  affectsSemanticDiagnostics?: true // true if option affects semantic diagnostics
  affectsEmit?: true // true if the options affects emit
  affectsProgramStructure?: true // true if program should be reconstructed from root files if option changes and does not affect module resolution as affectsModuleResolution indirectly means program needs to reconstructed
  affectsDeclarationPath?: true // true if the options affects declaration file path computed
  affectsBuildInfo?: true // true if this options should be emitted in buildInfo
  transpileOptionValue?: boolean | undefined // If set this means that the option should be set to this value when transpiling
  extraValidation?: unknown // (value: CompilerOptionsValue) => [DiagnosticMessage, ...string[]] | undefined; // Additional validation to be performed for the value to be valid
  disallowNullOrUndefined?: true // If set option does not allow setting null
}

/** @internal */
export interface CommandLineOptionOfStringType extends CommandLineOptionBase {
  type: 'string'
  defaultValueDescription?: string | undefined | DiagnosticMessage
}

/** @internal */
export interface CommandLineOptionOfNumberType extends CommandLineOptionBase {
  type: 'number'
  defaultValueDescription: number | undefined | DiagnosticMessage
}

/** @internal */
export interface CommandLineOptionOfBooleanType extends CommandLineOptionBase {
  type: 'boolean'
  defaultValueDescription: boolean | undefined | DiagnosticMessage
}

/** @internal */
export interface CommandLineOptionOfCustomType extends CommandLineOptionBase {
  type: Map<string, number | string> // an object literal mapping named values to actual values
  defaultValueDescription: number | string | undefined | DiagnosticMessage
  deprecatedKeys?: Set<string>
}

/** @internal */
export interface OptionsNameMap {
  optionsNameMap: Map<string, CommandLineOption>
  shortOptionNames: Map<string, string>
}

/** @internal */
export interface AlternateModeDiagnostics {
  diagnostic: DiagnosticMessage
  getOptionsNameMap: () => OptionsNameMap
}

/** @internal */
export interface DidYouMeanOptionsDiagnostics {
  alternateMode?: AlternateModeDiagnostics
  optionDeclarations: CommandLineOption[]
  unknownOptionDiagnostic: DiagnosticMessage
  unknownDidYouMeanDiagnostic: DiagnosticMessage
}

/** @internal */
export interface TsConfigOnlyOption extends CommandLineOptionBase {
  type: 'object'
  elementOptions?: Map<string, CommandLineOption>
  extraKeyDiagnostics?: DidYouMeanOptionsDiagnostics
}

/** @internal */
export interface CommandLineOptionOfListType extends CommandLineOptionBase {
  type: 'list' | 'listOrElement'
  element:
    | CommandLineOptionOfCustomType
    | CommandLineOptionOfStringType
    | CommandLineOptionOfNumberType
    | CommandLineOptionOfBooleanType
    | TsConfigOnlyOption
  listPreserveFalsyValues?: boolean
}

/** @internal */
export type CommandLineOption =
  | CommandLineOptionOfCustomType
  | CommandLineOptionOfStringType
  | CommandLineOptionOfNumberType
  | CommandLineOptionOfBooleanType
  | TsConfigOnlyOption
  | CommandLineOptionOfListType
