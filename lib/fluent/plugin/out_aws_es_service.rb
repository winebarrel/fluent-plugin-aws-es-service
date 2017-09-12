require 'fluent/plugin/out_elasticsearch'
require_relative 'elasticsearch_output_client_ext'

class Fluent::AwdEsServiceOutput < Fluent::ElasticsearchOutput
  Fluent::Plugin.register_output('aws_es_service', self)
  prepend ElasticsearchOutputClientExt
end
