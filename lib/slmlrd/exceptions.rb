module Slmlrd
  module Exceptions
    class LoginError < StandardError; end
    class ResponseCodeError < StandardError; end
    class UploadFailed < StandardError; end
  end
end
