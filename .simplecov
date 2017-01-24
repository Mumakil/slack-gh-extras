# frozen_string_literal: true


SimpleCov.start 'rails' do
  add_filter '/spec/'
  minimum_coverage 90
  minimum_coverage_by_file 80
end
