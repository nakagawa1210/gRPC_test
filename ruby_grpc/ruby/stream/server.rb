this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(File.dirname(this_dir), 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'msg_stream_services_pb'

class RectangleEnum
  def initialize(count)
    @count = count
  end

  def each
    return enum_for(:each) unless block_given?
    (0 ... @count).each do
      senddata = $array.shift
      $stop_time.push Time.now
      yield  Msg::SendData.new(length: senddata.length,
                               command: senddata.command,
                               dest: senddata.dest,
                               msgid: 7,
                               message: senddata.message)
    end
  end
end

class MsgServer < Msg::Frame::Service
  def initialize()
    $array = []
    @ID = []
    $start_time = []
    $stop_time = []
  end
  
  def send_msg(iddata, _call)
    @ID.push iddata
    count = iddata.msgid
    
    loop do
      break if $array.length != 0
      sleep(0.001)
    end
    wait = count / 100
    #sleep(wait)
    RectangleEnum.new(count).each
  end
  
  def recv_msg(data)
    data.each_remote_read do |recvdata|
      # timer_start
      $start_time.push Time.now
      
      $array.push recvdata
    end
    
    Msg::Response.new(length: 1,
                      command: 2,
                      dest: 3,
                      msgid: 4,
                      rescode: 5)
  end

  def time_result(iddata, _unused_call)
    (0...iddata.msgid).each {|n|
      puts "#{n} #{$stop_time.shift - $start_time.shift}"
    }
    
    Msg::Response.new(length: iddata.length,
                      command: iddata.command,
                      dest: iddata.dest,
                      msgid: 0,
                      rescode: iddata.length)
  end
end

def main ()
  s = GRPC::RpcServer.new
  s.add_http2_port('0.0.0.0:50051', :this_port_is_insecure)
  s.handle(MsgServer.new())

  s.run_till_terminated_or_interrupted([1, 'int', 'SIGQUIT'])
end

main

