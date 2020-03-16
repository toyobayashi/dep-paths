/// <reference types="node" />

export function findProjectRoot(start?: string): string
export function resolve (dirname: string, r: NodeRequire, request: string): string
export function getDepPaths(dirname: string, r: NodeRequire): string[]
export function getIncludes(): string[]
