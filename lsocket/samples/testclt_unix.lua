-- very simple test client, just connects to the server, sends what
-- you type and prints what you receive.
-- Demonstrates how to set up a unix domain client socket and communicate
-- through it, and how to determine whether the server has terminated.
--
-- Gunnar Zötl <gz@tset.de>, 2013-03
-- Do what you will with this.

addr = "./testsocket"

ls = require "lsocket"

client, err = ls.connect(addr)
if not client then
	print("error: "..err)
	os.exit(1)
end

-- wait for connect() to succeed or fail
ls.select(nil, {client})
ok, err = client:status()
if not ok then
	print("error: "..err)
	os.exit(1)
end

print "Socket info:"
for k, v in pairs(client:info()) do
	io.write(k..": "..tostring(v)..", ")
end
sock = client:info("socket")
print("\nSocket: "..sock.family)
peer = client:info("peer")
print("Peer: "..peer.family.." "..peer.addr)

print("Type quit to quit.")
repeat
	io.write("Enter some text: ")
	s = io.read()
	ok, err = client:send(s)
	if not ok then print("error: "..err) end
	ls.select({client})
	str, err = client:recv()
	if str then
		print("reply: "..str)
	elseif err then
		print("error: "..err)
	else
		print("server died, exiting")
		s = "quit"
	end
until s == "quit"

client:close()
