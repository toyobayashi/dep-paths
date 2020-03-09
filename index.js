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

function getDepPaths (dirname) {
  const pkg = require(path.join(dirname, './package.json'))

  const paths = []

  const deps = Array.from(new Set([...Object.keys(pkg.dependencies || {})]))

  deps.forEach(key => {
    let main
    try {
      main = require.resolve(key)
    } catch (_) {
      return
    }
    const dir = findProjectRoot(main)
    if (fs.existsSync(path.join(dir, 'CMakeLists.txt')) || fs.existsSync(path.join(dir, 'CMakelists.txt'))) {
      const relativeDir = path.relative(dirname, dir).replace(/\\/g, '/')
      paths.push(`${dir},${relativeDir}`)
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
  getDepPaths,
  findProjectRoot,
  getIncludes
}
