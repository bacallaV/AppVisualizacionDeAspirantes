import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() =>runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var usuario = TextEditingController();
  var contrasena = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(left: 30, right: 30, top: 250),
        child: Center(
          child: ListView(
            children: <Widget>[
              Text(
                'Login',
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 20.0,
                ),
              ),
              TextField(
                controller: usuario,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  icon: Icon(Icons.account_circle)
                ),
              ),
              TextField(
                controller: contrasena,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  icon: Icon(Icons.lock)
                ),
                obscureText: true,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
              FlatButton(
                child: Text('Ingresar'),
                color: Colors.teal,
                textColor: Colors.white,
                onPressed: (){
                  if(usuario.text=='admin' && contrasena.text=='admin'){
                    Navigator.pop(context);
                    final ruta = MaterialPageRoute(
                      builder: (context) => (Inicio())
                    );
                    Navigator.push(context, ruta);
                  }else{
                    return showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return AlertDialog(
                          title: Text('Usuario y/o contraseña incorrecto(s)'),
                          actions: <Widget>[
                            FlatButton(
                                child: Text("Aceptar"),
                                onPressed: (){
                                  Navigator.pop(context);
                                },
                              )
                          ],
                        );
                      }
                    );
                  }
                },
              )
            ],
          )
        ),
      ),
    );
  }
}

class Inicio extends StatefulWidget {
  Inicio({Key key}) : super(key: key);

  @override
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         title: Text('Inicio'),
       ),
       body: Center(
         child: Icon(Icons.data_usage),
       ),
       drawer: Drawer(
          child: ListView(
            children: <Widget>[
            UserAccountsDrawerHeader(
              accountEmail: null,
              accountName: Text('Admin'),
              currentAccountPicture: CircleAvatar(
                child: Icon(Icons.account_circle, size: 70.0,),
                maxRadius: 10,
                ),
              ),
            ListTile(
                title: Text('Listado de Aspirantes'),
                leading: Icon(
                  Icons.filter_list,
                  color: Colors.teal,
                  ),
                  onTap: (){
                    final ruta = MaterialPageRoute(
                      builder: (context) => Listado()
                    );
                    Navigator.push(context, ruta);
                },
              ),
            ],
          ),
        ),
    );
  }
}

class Listado extends StatefulWidget {
  Listado({Key key}) : super(key: key);

  @override
  _ListadoState createState() => _ListadoState();
}

class _ListadoState extends State<Listado> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listado de Aspirantes'),
      ),
       body: Center(
         child: FutureBuilder(
           future: getListado(),
           builder: (context, snapshot){
             if(snapshot.data==null){
                return Center(
                child: CircularProgressIndicator(),
              );
             }else{
               return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, indice){
                  return ListTile(
                    leading: Icon(Icons.verified_user),
                    title: Text(snapshot.data[indice].fecha),
                    subtitle: Text(snapshot.data[indice].total),
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(
                          builder: (BuildContext context) => new ListadoFecha(fecha: snapshot.data[indice].fecha,)
                          )
                        );
                      },
                    ),
                  );
                 },
               );
             }
           },
         ),
       ),
    );
  }
}

class ListadoFecha extends StatelessWidget {
  final String fecha;
  const ListadoFecha({Key key, this.fecha}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: Text(fecha),
       ),
      

       body: Center(
         child: FutureBuilder(
           future: getListadoFecha(fecha),
           builder: (context, snapshot){
             if(snapshot.data==null){
                return Center(
                  child: CircularProgressIndicator(),
              );
             }else{
               return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, indice){
                  return ListTile(
                    leading: Icon(Icons.verified_user),
                    title: Text(snapshot.data[indice].nombre+' '+snapshot.data[indice].apellido),
                    subtitle: Text('Desea estudiar en la UPIIZ: '+snapshot.data[indice].upiiz),
                  );
                 },
               );
             }
           },
         ),
       ),
    );
  }
}

class Aspirante {
  int id;
  String nombre;
  String apellido;
  String upiiz;

  Aspirante({this.id, this.nombre, this.apellido, this.upiiz});

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nombre": nombre,
      "correo": apellido,
      "contrasena": upiiz,
    };
  }

  factory Aspirante.fromJson(Map<String, dynamic> data)=> Aspirante(
    id:data["id"],
    nombre:data["nombre"],
    apellido:data["apellido"],
    upiiz:data["upiiz"]
  );

}

class AspirantesPorFecha {
  String fecha;
  String total;

  AspirantesPorFecha({this.fecha, this.total});

  Map<String, dynamic> toJson() {
    return {
      "fecha": fecha,
      "total": total,
    };
  }

  factory AspirantesPorFecha.fromJson(Map<String, dynamic> data)=> AspirantesPorFecha(
    fecha:data["fecha"],
    total:data["total"],
  );
}

Future<List<Aspirante>> getListadoFecha(String fecha) async{
  var url ='http://sistemas.upiiz.ipn.mx/isc/sira/api/actionReadAspiranteTotalFechaApp.php?accion=read&fecha=${fecha}';
  
  var respuestaAPI = await http.get(url);
  var res;
  List<Aspirante> aspirantes=[];
  
  //200 = Todo esta OK
  if(respuestaAPI.statusCode==200){
    res = json.decode(respuestaAPI.body);

    if(res["estado"]==1){
      for(var e in res["listado"] )
        aspirantes.add(Aspirante(
          nombre: e["nombre"].toString(),
          apellido: e["apelllido"].toString(),
          upiiz: e["upiiz"].toString(),
      ));
    }
  }else
    res = {"estado": 0, "mensaje": "Sin respuesta del Servidor"};

  print(res);

  return aspirantes;
}

Future<List<AspirantesPorFecha>> getListado() async{
  var url ='http://sistemas.upiiz.ipn.mx/isc/sira/api/actionReadAspiranteTotalApp.php?accion=read';
  
  var respuestaAPI = await http.get(url);
  var res;
  List<AspirantesPorFecha> aspirantes=[];
  
  //200 = Todo esta OK
  if(respuestaAPI.statusCode==200){
    res = json.decode(respuestaAPI.body);

    if(res["estado"]==1){
      for(var e in res["listado"] )
        aspirantes.add(AspirantesPorFecha(
          fecha: e["Fecha"].toString(),
          total: e["Total"].toString(),
      ));
    }
  }else
    res = {"estado": 0, "mensaje": "Sin respuesta del Servidor"};

  print(res);

  return aspirantes;
}