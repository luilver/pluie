require 'sms_tools/gsm_encoding'

module SmsTools
  class EncodingDetection
    remove_const(:MAX_LENGTH_FOR_ENCODING) if (defined?(MAX_LENGTH_FOR_ENCODING))
    MAX_LENGTH_FOR_ENCODING = {
        ascii: {
            normal:       156,
            concatenated: 153,
        },
        gsm: {
            normal:       156,
            concatenated: 153,
        },
        unicode: {
            normal:       70,
            concatenated: 67,
        },
    }.freeze

    attr :text

    def initialize(text)
      @text = text
    end

    def encoding
      @encoding ||=
          if text.ascii_only?
            :ascii
          elsif SmsTools.use_gsm_encoding? and GsmEncoding.valid?(text)
            :gsm
          else
            :unicode
          end
    end

    def ascii?
      encoding == :ascii
    end

    def gsm?
      encoding == :gsm
    end

    def unicode?
      encoding == :unicode
    end

    def concatenated?
      concatenated_parts > 1
    end

    def concatenated_parts
      if length <= MAX_LENGTH_FOR_ENCODING[encoding][:normal]
        1
      else
        (length.to_f / MAX_LENGTH_FOR_ENCODING[encoding][:concatenated]).ceil
      end
    end

    def maximum_length_for(concatenated_parts)
      message_type = concatenated_parts > 1 ? :concatenated : :normal

      concatenated_parts * MAX_LENGTH_FOR_ENCODING[encoding][message_type]
    end

    # Returns the number of symbols which the given text will eat up in an SMS
    # message, taking into account any double-space symbols in the GSM 03.38
    # encoding.
    def length
      length = text.length
      length += text.chars.count { |char| GsmEncoding.double_byte?(char) } if gsm?

      length
    end
  end
end