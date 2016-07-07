require "picture_upload_tool/version"
require 'fileutils'
require 'yaml'
require 'uri'
require 'typhoeus'

module PictureUploadTool
  class App

    def self.start
      new.start
    end

    def start
      load_yaml
      args = ARGV
      @delete = args.delete('-d')
      if @delete
        puts "Delete mode active"
      end
      files = ARGV
      if files.length == 0
        puts "Please enter some files or directories"
        exit 1
      end
      @files = files.flat_map{|i| File.directory?(i) ? Dir["#{i}/**/*"] : i }.reject{|i| File.directory?(i) }

      puts "#{@files.count} found. Starting upload"
      @files.each do |file|
        handle(file)
      end
    end


    def request(path:, params: {}, body: nil, method: :get, headers: {})
      request = Typhoeus::Request.new(
        URI.join(@config['server_address'], path).to_s,
        method: method,
        body: body,
        params: { token: @config['api_key']}.merge(params),
        headers: headers
      )
      request.run
    end

    def handle(file)
      md5 = Digest::MD5.file(file).to_s

      response = request(path: '/api/exists', params: { md5: md5 })
      if response.response_code == 404
        upload(file)
      elsif response.response_code == 200
        puts "#{file} exists.. skipping"
        delete(file)
      elsif response.response_code == 401
        puts "Error: 401, check api key"
        exit 1
      else
        puts "Error while uploading: #{response.status} #{response.response_body}"
        # File exists
      end
    end

    def delete(file)
      if @delete
        puts " .. File removed"
        File.unlink(file)
      end
    end

    def upload(file)
      file = File.open(file)
      size = File.size(file)

      puts "Uploading #{file.path}.. (#{(size / 1024.0 / 1024).round(1)}mb)"
      response = request(method: :post, path: '/', body: { file: file })
      if response.response_code == 200
        delete(file)
      else
        puts "  ERROR uploading: #{response.response_code}"
        puts response.response_body
      end
    ensure
      file.close
    end

    def load_yaml
      config_file = "#{ENV['HOME']}/.picture_upload_config.yml"
      if File.exists?(config_file)
        @config = YAML.load_file(config_file)
      else
        File.write(config_file, default_config.to_yaml)
        @config = default_config
        puts "#{config_file} written, please input api_key and server address"
        exit 1
      end
    end

    def default_config
      {
        'api_key' => '',
        'server_address' => 'http://localhost:3000/'
      }
    end
  end
  # Your code goes here...
end
