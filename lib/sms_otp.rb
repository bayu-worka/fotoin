class SmsOtp
  def initialize
    @client_id = ENV["XSIGHT_CLIENT_ID"]
    @client_secret = ENV["XSIGHT_CLIENT_SECRET"]
  end

  def get_access_token
    params = URI.encode_www_form({grant_type: "client_credentials"})
    auth = {username: @client_id, password: @client_secret}
    response = HTTParty.post("https://api.mainapi.net/token", 
              :body => params,
              :basic_auth => auth,
              :headers => { 'Content-Type' => 'application/x-www-form-urlencoded'}
              )
    if response.parsed_response["access_token"]
      @access_token = response.parsed_response["access_token"]
    else
      @error = response.parsed_response["error_description"]
    end
  end

  def request_otp(phone_number)
    if @access_token
      params = URI.encode_www_form({phoneNum: phone_number, digit: 6})
      result = HTTParty.put("https://api.mainapi.net/smsotp/1.0.1/otp/01010", 
                            :body => params,
                            :headers => { 'Content-Type' => 'application/x-www-form-urlencoded', 'Authorization' => "Bearer #{@access_token}" } )
      if result.parsed_response["status"]
        @message_id = result.parsed_response["msgId"]
      else
        @error = result.parsed_response.try(:[], "net").try(:[], "mainapi").try(:[], "fault").try(:[], "message") || "request otp failed"
      end
    else
      @error
    end
  end

  def validate_otp(otp)
    if @access_token
      params = URI.encode_www_form({otpstr: otp, digit: 6})
      response = HTTParty.post("https://api.mainapi.net/smsotp/1.0.1/otp/01010/verifications", 
                                :body => params,
                                :headers => { 'Content-Type' => 'application/x-www-form-urlencoded', 'Authorization' => "Bearer #{@access_token}" } )
      if response.parsed_response["status"]
        @validate_status = true
      else
        @error = response.parsed_response["message"]
      end
    else
      @error
    end
  end
end