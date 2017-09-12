require 'aws-sdk-core'
require 'faraday_middleware/aws_sigv4'

module ElasticsearchOutputClientExt
  def self.prepended(mod)
    mod.config_param :region, :string
    mod.config_param :access_key_id, :string, default: nil
    mod.config_param :secret_access_key, :string, default: nil
    mod.config_param :credentials_provider, :hash, default: nil
  end

  # Copyright 2017 Uken Studios, Inc.
  # https://github.com/uken/fluent-plugin-elasticsearch/blob/v1.9.6/lib/fluent/plugin/out_elasticsearch.rb#L144
  def client
    @_es ||= begin
      excon_options = { client_key: @client_key, client_cert: @client_cert, client_key_pass: @client_key_pass }
      adapter_conf = lambda do |f|
        # Append aws_sigv4 middleware
        f.request :aws_sigv4,
          service: 'es',
          region: @region,
          access_key_id: @access_key_id,
          secret_access_key: @secret_access_key,
          credentials_provider: build_credentials_provider(@credentials_provider)

        f.adapter :excon, excon_options
      end

      transport = Elasticsearch::Transport::Transport::HTTP::Faraday.new(get_connection_options.merge(
                                                                          options: {
                                                                            reload_connections: @reload_connections,
                                                                            reload_on_failure: @reload_on_failure,
                                                                            resurrect_after: @resurrect_after,
                                                                            retry_on_failure: 5,
                                                                            transport_options: {
                                                                              headers: { 'Content-Type' => 'application/json' },
                                                                              request: { timeout: @request_timeout },
                                                                              ssl: { verify: @ssl_verify, ca_file: @ca_file }
                                                                            }
                                                                          }), &adapter_conf)
      es = Elasticsearch::Client.new transport: transport

      begin
        raise ConnectionFailure, "Can not reach Elasticsearch cluster (#{connection_options_description})!" unless es.ping
      rescue *es.transport.host_unreachable_exceptions => e
        raise ConnectionFailure, "Can not reach Elasticsearch cluster (#{connection_options_description})! #{e.message}"
      end

      log.info "Connection opened to Elasticsearch cluster => #{connection_options_description}"
      es
    end
  end

  def build_credentials_provider(credentials_provider)
    return nil unless credentials_provider

    klass = credentials_provider.fetch('class')
    credentials_provider.delete('class')
    const_get(klass).new(credentials_provider)
  end
end
