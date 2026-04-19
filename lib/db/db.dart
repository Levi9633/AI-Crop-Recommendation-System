import 'package:mysql_client/mysql_client.dart';

class DBService {
  static Future<MySQLConnection> connect() async {
    final conn = await MySQLConnection.createConnection(
      host: 'mysql-1742ec2e-lanipe-730f.d.aivencloud.com',
      port: 23845,
      userName: 'avnadmin',
      password: 'AVNS_nXZPrTWPjDgff_TT8IV',
      databaseName: 'defaultdb',
      secure: true,
    );
    await conn.connect();
    return conn;
  }
}



// import 'package:mysql_client/mysql_client.dart';
//
// class DBService {
//   static Future<MySQLConnection> connect() async {
//     final host = 'mysql-1742ec2e-lanipe-730f.d.aivencloud.com';
//     final port = 23845;
//     final username = 'avnadmin';
//     final password = 'AVNS_nXZPrTWPjDgff_TT8IV';
//     final database = 'default';
//
//     MySQLConnection? conn;
//
//     try {
//       print('Trying to connect to the database...');
//       conn = await MySQLConnection.createConnection(
//         host: host,
//         port: port,
//         userName: username,
//         password: password,
//         databaseName: database,
//         secure: true,
//       );
//       await conn.connect();
//       print('Database connection established.');
//       return conn;
//     } catch (e) {
//       print('Database connection error: $e');
//       rethrow;
//     }
//   }
// }

