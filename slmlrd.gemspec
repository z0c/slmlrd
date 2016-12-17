# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'NAME'
  spec.version       = '1.0'
  spec.authors       = ['Nuno Pereira']
  spec.email         = ['nvnivs@gmail.com']
  spec.summary       = 'messing about'
  spec.description   = 'just messing about.'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = ['lib/*.rb']
  spec.executables   = ['bin/slmlrd']
  spec.test_files    = ['tests/*.rb']
  spec.require_paths = ['lib']
end
