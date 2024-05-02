// import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
//   late IO.Socket socket;
//   dynamic dataTyping;

//   createSocketConnection() {
//     socket =
//         IO.io("https://abtest.schoolofparenting.id:3002", <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//     });

//     if (!socket.connected) {
//       socket.connect();
//     }

//     this.socket.on("connect", (_) => wLog('Connected'));
//     this.socket.on("disconnect", (_) => wLog('Disconnected'));
//     this.socket.on("display", _updateData);
//   }

//   void _updateData(dynamic data) {
//     dataTyping = data;
//   }

//   dynamic listen(String event) async {
//     dynamic dynData;
//     if (event == "display") {
//       dynData = dataTyping;
//     }
//     //wLog("dinda__" + dynData.toString());
//     return dynData;
//   }

//   disconnect() {
//     this.socket.disconnect();
//     wLog("disconnected");
//   }

//   isConnected() {
//     return this.socket.connected;
//   }

//   reconnect() {
//     this.socket.connect();
//     wLog("reconnected");
//   }

//   typing(bool isTyping) {
//     this.socket.emit('typing', {
//       "user": "users",
//       "email": "email",
//       "room": "room",
//       "typing": isTyping,
//     });
//   }

//   sendMessage(dynamic data, String lastId) {
//     this.socket.emit("new_message", {
//       "idleveluser": data['id_user'],
//       "nama": data['nama_user'],
//       "level": data['level_user'],
//       "idchat": lastId,
//       "pesan": data['pesan'],
//       "file": "",
//       "idchatreply": "",
//       "reply": "",
//       "created_at": getCurrentChatTime()
//     });
//   }
}
