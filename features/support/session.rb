module OurSession
  def session
    last_request.env['rack.session']
  end
end
World(OurSession)