module Slmlrd
  # Utility class to normalize stuff
  class Normalizer
    def normalize_title(sentence)
      sentence = remove_verification(sentence)
      sentence = remove_isolated_f_brackets(sentence)
      sentence = remove_isolated_f_parenthesis(sentence)
      sentence = replace_f_parenthesis_begin_of_word(sentence)
      sentence = replace_f_brackets_begin_of_word(sentence)
      sentence
    end

    private

    def replace_f_parenthesis_begin_of_word(s)
      s.gsub(/\(([fF])\)/, '\1')
    end

    def replace_f_brackets_begin_of_word(s)
      s.gsub(/\[([fF])\]/, '\1')
    end

    def remove_isolated_f_brackets(s)
      s.gsub(/\B\[([0-9]*[fF]{1}[0-9]*)\]\B/, '').strip
    end

    def remove_isolated_f_parenthesis(s)
      s.gsub(/\B\(([0-9]*[fF]{1}[0-9]*)\)\B/, '').strip
    end

    def remove_verification(s)
      s.gsub(/\B\[(verification)\]\B/i, '').strip
    end
  end
end
