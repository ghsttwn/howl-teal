--- Teal bundle entrypoint

import mode, inspection from howl

provide_module 'tl'

mode_reg =
  name: 'teal'
  shebangs: {'/tl.*$', '/env tl.*$'}
  extensions: {'tl'}
  create: bundle_load 'teal_mode'

mode.register mode_reg

inspection.register {
  name: 'tl',
  factory: ->
    bundle_load 'tl_inspector'
}

unload = ->
  mode.unregister 'teal'
  inspection.unregister 'tl'

return {
  info:
    author: 'Martín Aguilar',
    description: 'Teal mode',
    license: 'MIT'
  :unload
}
