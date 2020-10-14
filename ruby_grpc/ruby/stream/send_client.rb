this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(File.dirname(this_dir), 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'msg_stream_services_pb'

# from a list of Features.
class MakeRecvData
  def initialize(count)
    @count = count
  end

  def each
    return enum_for(:each) unless block_given?
    (0 ... @count).each do |num|
      message = "data num = #{num}"
    
      length = message.length
      command = 1
      dest = num

      yield  Msg::RecvData.new(length: length,
                               command: command,
                               dest: dest,
                               message: message)
    end
  end
end


def main()
  count = ARGV.size > 0 ?  ARGV[0].to_i : 10
  hostname = ARGV.size > 1 ?  ARGV[1] : 'localhost:50051'
  stub = Msg::Frame::Stub.new(hostname, :this_channel_is_insecure)

  senddata = MakeRecvData.new(count)
  response = stub.recv_msg(senddata.each)
  
  p "#{response}"
end

main
