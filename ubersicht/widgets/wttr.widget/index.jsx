//
// Shows the current wttr.in forecast on your desktop
//
//
// Change language and city with the two parameter below.
// check http://wttr.in/:translation for a list of available languanges.
//
//

import * as util from 'util'

import {React} from 'uebersicht'

export const lang = 'en'
export const city = 'Vancouver'
// export const city = '49.25,-123.17'

export const refreshFrequency = 1000 * 60 * 30 // 30min
const retries = 5
/** @param {number} n */
const retryDelay = (n) => 0|((n ** Math.log2(3)) * 30000)

export const className = /*styl*/`
  // position on screen
  left: 135px;
  top: 80px;

  position: fixed;
  -webkit-font-smoothing: antialiased; // nicer font rendering
  // -webkit-backdrop-filter: blur(5px);
  color: #efefef;

  .container {
    border-radius: 5px;
    background-color: #00000000;
    // filter: blur(4px);
  }

  .background {
    background-color: #00000000;
    position: absolute;
    width: 100%;
    height: 100%;
  }

  pre {
    font-size: 11px;
    font-weight: 450;
    // font-family: "FantasqueSansM Nerd Font", "SF Mono", "DejaVu Sans Mono", Menlo, "Lucida Sans Typewriter", "Lucida Console", monaco, "Bitstream Vera Sans Mono", monospace;
    font-family: "Fira Code", "Iosevka Term SS17", Menlo, "SF Mono", "Lucida Sans Typewriter", "Lucida Console", monaco, "Bitstream Vera Sans Mono", monospace;
    border-radius: 5px;
    isolation: isolate;
    padding: 8px 8px 14px;
    transition: all 0.5s cubic-bezier(0,.77,.57,.96);
    background: radial-gradient(ellipse 10% 8% at 10% 8%, #00000070, #00000070 10%, transparent),
            // radial-gradient(ellipse 15% 15% at 20% 10%, #00000070, #00000070 10%, transparent),
            radial-gradient(ellipse 10% 15% at 10% 30%, #00000070, #00000070 10%, transparent),
            radial-gradient(ellipse 10% 15% at 10% 50%, #00000070, #00000070 10%, transparent),
            radial-gradient(ellipse 10% 15% at 10% 70%, #00000070, #00000070 10%, transparent),
            radial-gradient(ellipse 10% 10% at 10% 90%, #00000070, #00000070 10%, transparent),
            // radial-gradient(ellipse 15% 15% at 30% 10%, #00000070, #00000070 10%, transparent),
            radial-gradient(ellipse 30% 30% at 30% 30%, #00000070, #00000070 10%, transparent),
            radial-gradient(ellipse 15% 15% at 30% 50%, #00000070, #00000070 10%, transparent),
            radial-gradient(ellipse 30% 30% at 30% 70%, #00000070, #00000070 10%, transparent),
            radial-gradient(ellipse 25% 15% at 35% 85%, #00000090, #00000070 10%, transparent),
            radial-gradient(ellipse 12% 10% at 30% 90%, #00000070, #00000070 10%, transparent),
            // radial-gradient(ellipse 15% 15% at 50% 10%, #00000070, #00000070 10%, transparent),
            // radial-gradient(ellipse 15% 15% at 50% 30%, #00000070, #00000070 10%, transparent),
            radial-gradient(ellipse 30% 30% at 50% 50%, #00000070, #00000070 10%, transparent),
            radial-gradient(ellipse 15% 15% at 50% 70%, #00000070, #00000070 10%, transparent),
            radial-gradient(ellipse 15% 10% at 50% 90%, #00000070, #00000070 10%, transparent),
            radial-gradient(ellipse 18% 15% at 82% 50%, #00000090, #00000070 10%, transparent),
            // radial-gradient(ellipse 15% 15% at 70% 30%, #00000070, #00000070 10%, transparent),
            radial-gradient(ellipse 15% 15% at 70% 50%, #00000090, #00000070 10%, transparent),
            radial-gradient(ellipse 30% 30% at 70% 70%, #00000090, #00000070 10%, transparent),
            radial-gradient(ellipse 12% 10% at 70% 90%, #00000090, #00000070 10%, transparent),
            radial-gradient(ellipse 18% 15% at 82% 85%, #00000090, #00000070 10%, transparent),
            // radial-gradient(ellipse 10% 15% at 90% 30%, #00000070, #00000070 10%, transparent),
            radial-gradient(ellipse 10% 15% at 90% 50%, #00000090, #00000070 10%, transparent),
            radial-gradient(ellipse 10% 15% at 90% 70%, #00000090, #00000070 10%, transparent),
            radial-gradient(ellipse 10% 10% at 90% 90%, #00000090, #00000070 10%, transparent);
    text-shadow: #000 0 1px 2px,#000 0 1px 4px,#000 0 1px 8px,#000 0 1px 8px,#000 0 1px 16px,#000 0 1px 16px;
  }

  pre:hover {
    border-radius: 5px;
    background: #00000070;
    box-shadow: 0 0 5px #00000068, 0 0 25px #00000060;
    backdrop-filter: blur(4px) grayscale(0.2);
    text-shadow: x,#000 0 1px 4px,#000 0 1px 8px;
    animation: pulse 1s infinite;
  }

  @keyframes pulse {
    0% {
      background-color: #00000070;
    }
    100% {
      background-color: #0000006e;
    }
  }
`

let prevOutput;
/** @type {import('uebersicht').CommandFunction} */
export const command = (dispatch, n = 1) => {
  fetchWttr()
    .then((output) => {
      prevOutput = output
      dispatch({ output })
    })
    .catch((error) => {
      dispatch({ error, output: prevOutput })
      if (n <= retries) {
        setTimeout(command, retryDelay(n), dispatch, n + 1);
      }
    })
}

async function fetchWttr() {
  const resp = await fetch(`https://wttr.in/${city}\?2nq`, {
    headers: {
      'Accept-Language': lang
    }
  });
  const html = await resp.text();
  const tmpl = document.createElement('template');
  tmpl.innerHTML = html;
  return (tmpl.content.querySelector('style')?.outerHTML ?? '') + '\n' + (tmpl.content.querySelector('pre')?.outerHTML ?? '')
}

/** @type {React.FC<import('uebersicht').DefaultProps>} */
export const render = (props) =>
  <>
    {props.output && <>
      <div className="background"></div>
      <div
        className="container"
        dangerouslySetInnerHTML={{
          __html: props.output ?? '',
        }}
      />
    </>}
    {props.error &&
      <pre>{util.inspect({...props.error})}</pre>
    }
  </>


// export const command = `
// 	cd wttr.widget &&
// 	curl -s ${lang}.wttr.in/${city}\?0tq |
// 	./terminal-to-html.sh
// `

// export const render = (props) => {
//   const {error, output} = props
//   if (error) {
//     return typeof error === 'string' ? error : util.inspect(error)
//   }
//   return (
//     <div>
//       <link rel="stylesheet" href="wttr.widget/terminal-colors.css" />
//       <pre
//         dangerouslySetInnerHTML={{
//           __html: output.split('\n').slice(0, 24).join('\n'),
//         }}
//       />
//     </div>
//   )
// }
