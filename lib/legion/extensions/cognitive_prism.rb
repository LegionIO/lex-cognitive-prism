# frozen_string_literal: true

require 'securerandom'

require_relative 'cognitive_prism/version'
require_relative 'cognitive_prism/helpers/constants'
require_relative 'cognitive_prism/helpers/spectral_component'
require_relative 'cognitive_prism/helpers/beam'
require_relative 'cognitive_prism/helpers/prism_engine'
require_relative 'cognitive_prism/runners/cognitive_prism'
require_relative 'cognitive_prism/client'

module Legion
  module Extensions
    module CognitivePrism
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
