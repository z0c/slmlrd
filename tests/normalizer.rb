require_relative '../lib/slmlrd/normalizer'
require 'test/unit'

module Slmlrd
  # Test cases for Normalizer
  class TestNormalizer < Test::Unit::TestCase
    def test_f_parenthesis_begin_of_word
      sut = Normalizer.new
      title = 'asfdaf (f)rom asfafs'
      expected = 'asfdaf from asfafs'
      actual = sut.normalize_title(title)
      assert_equal expected, actual
    end

    def test_cf_parenthesis_begin_of_word
      sut = Normalizer.new
      title = 'asfdaf (F)rom asfafs'
      expected = 'asfdaf From asfafs'
      actual = sut.normalize_title(title)
      assert_equal expected, actual
    end

    def test_f_brackets_begin_of_word
      sut = Normalizer.new
      title = 'sdasadds ad adsd[f]dasd ds'
      expected = 'sdasadds ad adsdfdasd ds'
      actual = sut.normalize_title(title)
      assert_equal expected, actual
    end

    def test_remove_isolated_f_brackets
      sut = Normalizer.new
      title = 'dsadsa a Vasfsfa sfadf ;D [f]'
      expected = 'dsadsa a Vasfsfa sfadf ;D'
      actual = sut.normalize_title(title)
      assert_equal expected, actual
    end

    def test_remove_f_parenthesis_end_of_sentence
      sut = Normalizer.new
      title = 'dsadsa a Vasfsfa sfadf ;D (f)'
      expected = 'dsadsa a Vasfsfa sfadf ;D'
      actual = sut.normalize_title(title)
      assert_equal expected, actual
    end

    def test_remove_f_parenthesis_beggining_of_sentence
      sut = Normalizer.new
      title = '(f) dsfsdfs fdsfsd dsfdfs'
      expected = 'dsfsdfs fdsfsd dsfdfs'
      actual = sut.normalize_title(title)
      assert_equal expected, actual
    end

    def test_remove_fnum_brackets_end_of_sentence
      sut = Normalizer.new
      title = 'ds asdasd afasf af? [F64]'
      expected = 'ds asdasd afasf af?'
      actual = sut.normalize_title(title)
      assert_equal expected, actual
    end

    def test_remove_fnum_parenthesis_end_of_sentence
      sut = Normalizer.new
      title = 'ds asdasd afasf af? (F64)'
      expected = 'ds asdasd afasf af?'
      actual = sut.normalize_title(title)
      assert_equal expected, actual
    end

    def test_remove_numf_brackets_end_of_sentence
      sut = Normalizer.new
      title = 'ds asdasd afasf af? [22F]'
      expected = 'ds asdasd afasf af?'
      actual = sut.normalize_title(title)
      assert_equal expected, actual
    end

    def test_remove_numf_parenthesis_end_of_sentence
      sut = Normalizer.new
      title = 'ds asdasd afasf af? (54F)'
      expected = 'ds asdasd afasf af?'
      actual = sut.normalize_title(title)
      assert_equal expected, actual
    end

    def test_remove_verification_brackets_beggining_of_sentence
      sut = Normalizer.new
      title = '[Verification] Vdsfsd dasasd'
      expected = 'Vdsfsd dasasd'
      actual = sut.normalize_title(title)
      assert_equal expected, actual
    end
  end
end
