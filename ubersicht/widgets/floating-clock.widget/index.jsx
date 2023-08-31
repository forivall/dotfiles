/// <reference types="../../types.d.ts" />

import {React, css} from 'uebersicht'

export const className = `
  width: 100%;
  height: 100%;
`

const MINUTE = 60000;
const TRANSITION = 1600;

const clock = css`
  position: absolute;
  bottom: -40px;
  right: 36px;
  gap: 15px;
  opacity: 0.85;
  color: #fff6e9;
  font-family: Futura Medium;
  text-shadow: 1px 1px 5px #000000A0, 1px 1px 25px #00000080;
  transition: opacity ${TRANSITION/1000}s cubic-bezier(0.61, 1, 0.88, 1);
`

// font-size: 340px;
const hourMinutes = css`
  font-weight: 100;
  font-size: 280px;
`
const amPm = css`
  font-size: 130px;
  font-weight: 400;
`
const ch = css`
  width: 1ch;
`
const hideClass = css`
  opacity: 0 !important;
  transition: opacity ${TRANSITION/1000}s cubic-bezier(0.12, 0, 0.39, 0);
`

let tockTimeout;
let tickTimeout;

/**
 * @param {(event: object) => void} dispatch
 */
export function init(dispatch) {
  const tock = () => dispatch(0);
  (function update() {
    dispatch(1)
    clearTimeout(tockTimeout);
    clearTimeout(tickTimeout);
    tockTimeout = setTimeout(tock, TRANSITION + 10);
    tickTimeout = setTimeout(update, MINUTE - (Date.now() % MINUTE))
  })()
}

export const initialState = () => ({ tick: 1 })
export const updateState = (tock) => ({ tick: tock });

/**
 * @param {Date} time
 */
function formatTime(time) {
  const minNum = time.getMinutes()
  let hourNum = time.getHours()
  const key = `${minNum}:${hourNum}`
  let am_pm = 'AM'
  if (hourNum > 12) {
    hourNum -= 12
    am_pm = 'PM'
  }
  if (hourNum === 0) {
    hourNum = 12
    am_pm = 'AM'
  }
  const hour = `${hourNum}`;
  const [ch0, ch1] = hourNum < 10 ? ['', hour] : hour;

  const min = minNum < 10 ? '0' + minNum : `${minNum}`
  const [cm0, cm1] = min;
  return {ch0, ch1, cm0, cm1, hour, min, am_pm, key}
}

/**
 * @param {Date} time
 * @param {boolean | number} [hide]
 */
function renderDate(time, hide) {
  const {ch0, ch1, cm0, cm1, am_pm, key} = formatTime(time);
  return <div className={hide ? `${clock} ${hideClass}` : clock} key={key}>
    <span className={hourMinutes}>
      {ch0}<span className={ch}>{ch1}</span>:<span className={ch}>{cm0}</span><span className={ch}>{cm1}</span>
    </span>
    <span className={amPm}>{am_pm}</span>
  </div>
}

export const render = (props) => {
  const state = props;
  const time = new Date()
  const prev = new Date(time.valueOf() - MINUTE);
  console.log('tick', state.tick)

  return (<>
    {renderDate(time, state.tick)}
    {renderDate(prev, !state.tick)}
  </>)
}
