module CaptchaGenerator
  extend self

  def g text, width = 100, height = 28
    text = text.upcase

    params = ['-fill darkblue', '-background white']
    params << "-size #{width}x#{height}"
    params << "-wave #{distortion}"
    params << '-gravity "Center"'
    params << '-pointsize 22'
    params << '-implode 0.2'

    dst = Tempfile.new(['neolion_captcha', '.png'], Dir::tmpdir)
    dst.binmode

    params << "label:'#{text}' \"#{File.expand_path(dst.path)}\""

    run(params.join(' '))

    dst.close

    read_as_base64 File.expand_path(dst.path)
  end

  private

    def distortion
      [0 + rand(2), 80 + rand(20)].join('x')
    end

    def run params = "", expected_outcodes = 0
      command = %Q[convert #{params}].gsub(/\s+/, " ")
      command = "#{command} 2>&1"

      output = `#{command}`

      unless [expected_outcodes].flatten.include?($?.exitstatus)
        raise ::StandardError, "Error while running #{command}"
      end

      output
    end

    def read_as_base64 filepath
      data = Base64.encode64(File.binread(filepath))
      ['data:image/png;base64,', data].join.gsub(/\n/, '')
    end
end
