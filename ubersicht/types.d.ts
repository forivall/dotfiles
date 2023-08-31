declare module 'uebersicht' {
  import request from 'superagent'
  import {css} from 'emotion'
  import styled from '@emotion/styled'
  import React from 'react'
  function run(command: string): Promise<string>
  function run(
    command: string,
    callback: (err: Error | undefined, text: string | undefined) => void
  ): void
  export {run, request, css, styled, React}
}
