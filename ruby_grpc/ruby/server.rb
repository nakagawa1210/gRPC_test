this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'msg_bro_services_pb'

$array = []
$ID = []
$start_time = []
$stop_time = []

class MsgServer < Msg::Frame::Service
  def send_msg(iddata, _unused_call)

    loop do
      begin
        break if $array.length != 0
        sleep(0.00001)
      end
    end
    
    senddata = $array.shift
    
    Msg::SendData.new(length: senddata.length,
                      command: senddata.command,
                      dest: senddata.dest,
                      msgid: iddata.msgid,
                      message: senddata.message)
  end

  def check_msg(iddata, _unused_call)

    # timer_stop
    $stop_time.push Time.now
    
    Msg::Response.new(length: iddata.length,
                      command: iddata.command,
                      dest: iddata.dest,
                      msgid: 0,
                      rescode: iddata.length)
  end
  
  def recv_msg(recvdata, _unused_call)

    # timer_start
    $start_time.push Time.now
    
    $array.push recvdata
    
    Msg::Response.new(length: recvdata.length,
                      command: recvdata.command,
                      dest: recvdata.dest,
                      msgid: 0,
                      rescode: $array.length)
  end

  def recv_id(iddata, _unused_call)
    $ID.push iddata.msgid

    Msg::Response.new(length: iddata.length,
                      command: iddata.command,
                      dest: iddata.dest,
                      msgid: 0,
                      rescode: $array.length)
  end

  def time_result(iddata, _unused_call)
    n = 0
    (1...($start_time.length + 1)).each {|start|
      puts "#{n+=1} #{$stop_time.shift - $start_time.shift}"
    }
    
    Msg::Response.new(length: iddata.length,
                      command: iddata.command,
                      dest: iddata.dest,
                      msgid: 0,
                      rescode: iddata.length)
  end
end

def main
  s = GRPC::RpcServer.new
  s.add_http2_port('0.0.0.0:50051', :this_port_is_insecure)
  s.handle(MsgServer)

  s.run_till_terminated_or_interrupted([1, 'int', 'SIGQUIT'])
end

main
