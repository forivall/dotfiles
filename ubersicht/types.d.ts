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
  export {run, request, css, styled, React};

  export type CommandFunction<A = CommandEvent> = (dispatch: Dispatch<A>) => void;
  export type Dispatch<A> = (action: A) => void;
  export type Command = string | CommandFunction<any>;
  export interface OutputEvent {
    error?: never;
    output: string;
  }
  export interface ErrorEvent {
    error: Error;
  }
  export type CommandEvent = OutputEvent | ErrorEvent;
  export interface DefaultProps {
    error?: CommandEvent['error'];
    output?: OutputEvent['output'];
  }
}
