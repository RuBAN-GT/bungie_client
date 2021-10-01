# frozen_string_literal: true

class String
  # Transform string to snake case
  def underscore
    gsub(/::/, '/')
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr('- ', '_')
      .downcase
  end
end
