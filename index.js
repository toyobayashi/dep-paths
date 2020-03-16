const path = require('path')
const fs = require('fs')

function findProjectRoot (start) {
  let current = start ? path.resolve(start) : process.cwd()
  let previous = ''
  do {
    const target = path.join(current, 'package.json')
    if (fs.existsSync(target) && fs.statSync(target).isFile()) {
      return current
    }
    previous = current
    current = path.dirname(current)
  } while (current !== previous)
  return ''
}

function resolve (dirname, r, request) {
  const main = r.resolve(request)
  const dir = findProjectRoot(main)
  if (fs.existsSync(path.join(dir, 'CMakeLists.txt')) || fs.existsSync(path.join(dir, 'CMakelists.txt'))) {
    const relativeDir = path.relative(dirname, dir).replace(/\\/g, '/')
    return `${dir},${relativeDir}`
  }
  return ''
}

function getDepPaths (dirname, r) {
  const pkg = require(path.join(dirname, './package.json'))

  const paths = []

  const deps = Array.from(new Set([...Object.keys(pkg.dependencies || {})]))

  deps.forEach(moduleName => {
    try {
      const pathListComma = resolve(dirname, r, moduleName)
      if (pathListComma) paths.push(pathListComma)
    } catch (_) {
      return
    }
  })

  return paths
}

function getIncludes () {
  return [
    path.join(__dirname, 'dep.cmake')
  ]
}

module.exports = {
  findProjectRoot,
  resolve,
  getDepPaths,
  getIncludes
}
