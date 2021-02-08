class ActionDispatch::Request
  def session
    @session ||= SessionMock.new
  end
end
