import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quizstar/resultpage.dart';
import 'package:sign_button/sign_button.dart';
//import 'dart:async';

class getjson extends StatelessWidget {
  // accept the langname as a parameter
  
  String langname;
  String assettoload;
  getjson(this.langname,[this.assettoload="assets/Nivel 1.json"]);
  
  // se asigna a una varible el JSON correspondiente a cada nivel
  setasset() {
    if (langname == "NIVEL 1") {
      assettoload = "assets/Nivel 1.json";
    } else if (langname == "NIVEL 2") {
      assettoload = "assets/Nivel 1.json";
    } else if (langname == "NIVEL 3") {
      assettoload = "assets/Nivel 1.json";
    } else if (langname == "NIVEL 4") {
      assettoload = "assets/Nivel 1.json";
    } else {
      assettoload = "assets/Nivel 1.json";
    }
  }

  @override
  Widget build(BuildContext context) {
    // esta función se llama antes de la compilación para que
    // la cadena assettoload está disponible en DefaultAssetBuilder
    setasset();
    // y ahora devolvemos FutureBuilder para cargar y decodificar JSON
    return FutureBuilder(
      future:
          DefaultAssetBundle.of(context).loadString(assettoload, cache: false),
      builder: (context, snapshot) {
        List mydata = json.decode(snapshot.data.toString());
        if (mydata == null) {
          return Scaffold(
            body: Center(
              child: Text(
                "Loading",
              ),
            ),
          );
        } else {
          return quizpage(mydata: mydata);
        }
      },
    );
  }
}

class quizpage extends StatefulWidget {
  final List mydata;

  quizpage({Key? key, required this.mydata}) : super(key: key);
  @override
  _quizpageState createState() => _quizpageState(mydata);
}

class _quizpageState extends State<quizpage> {
  final List mydata;
  _quizpageState(this.mydata);

  Color colortoshow = Colors.indigoAccent;
  Color right = Colors.green;
  Color wrong = Colors.red;
  int marks = 0;
  int i = 1;
  bool disableAnswer = false;
  // varibale extra para iterar
  int j = 1;
  int timer = 30;
  String showtimer = "30";
  var random_array;

  Map<String, Color> btncolor = {
    "a": Colors.indigoAccent,
    "b": Colors.indigoAccent,
    "c": Colors.indigoAccent,
    "d": Colors.indigoAccent,
  };

  bool canceltimer = false;

  // código insertado para elegir preguntas al azar
  // para crear los elementos de la matriz, use aleatoriamente el módulo dart: math
  // -----     CÓDIGO PARA GENERAR ARRAY AL ALEATORIO

  genrandomarray(){
    var distinctIds = [];
    var rand = new Random();
      for (int i = 0; ;) {
      distinctIds.add(rand.nextInt(5)+1);//si o si tiene que ser mas uno para que no nos devuelva el valor 0
        random_array = distinctIds.toSet().toList();// solo entre 1 y 5
        if(random_array.length < 5){//podría elegir un array mas grande para que haya menos chance de que salga la misma 
          continue;                 //pregunta
        }else{
          break;
        }
      }
      print(random_array);
  }
  // La función anterior no devuelve un rray con el orden de las preguntas
  // anulando la función initstate para iniciar el temporizador cuando se crea esta pantalla
  @override
  void initState() {
    starttimer();
    genrandomarray();
    super.initState();
  }

  // anulando la función setstate para que se llame solo si está montada
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

//CONTROL DE CRONÓMETRO
  void starttimer() async { 
    const onesec = Duration(seconds: 1);
    Timer.periodic(onesec, (Timer t) {
      setState(() {
        if (timer < 1) {
          t.cancel();
          nextquestion();
        } else if (canceltimer == true) {
          t.cancel();
        } else {
          timer = timer - 1;
        }
        showtimer = timer.toString();
      });
    });
  }
 //MUESTRA SIGUIENTE PREGUNTA
  void nextquestion() {
    canceltimer = false;
    timer = 30; //inicializa el tiempo en 30 segundos
    setState(() {
      if (j < 5) {//controla que las preguntas sean solo 5
        i = random_array[j];
        j++;
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(//se dirige a la página de resultados
          builder: (context) => resultpage(marks: marks),//le manda como parámetro el puntaje
        ));
      }
     // muestra las preguntas
      btncolor["a"] = Colors.indigoAccent;
      btncolor["b"] = Colors.indigoAccent;
      btncolor["c"] = Colors.indigoAccent;
      btncolor["d"] = Colors.indigoAccent;
      disableAnswer = false;
    });
    starttimer();//inicializa el cronómetro
  }

  void checkanswer(String k) { //chequea que las preguntas 
    if (mydata[2][i.toString()] == mydata[1][i.toString()][k]) {
      marks = marks + 5; //suma puntaje
     // cambiando la variable de color a verde debido a que es correcta
      colortoshow = right;
    } else {
      // de lo contrario no suma puntos y indica la variable roja
      colortoshow = wrong;
    }
    setState(() {
      // aplicar el color cambiado al botón en particular que se seleccionó
      btncolor[k] = colortoshow;
      canceltimer = true;
      disableAnswer = true;
    });
    // próxima pregunta();
    // cambió la duración del temporizador a 1 segundo
    Timer(Duration(seconds: 2), nextquestion);
  }

  Widget choicebutton(String k) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 20.0,
      ),
      child: MaterialButton(
        onPressed: () => checkanswer(k),
        child: Text(
          mydata[1][i.toString()][k],
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Alike",
            fontSize: 16.0,
          ),
          maxLines: 1,
        ),
        color: btncolor[k],
        splashColor: Colors.indigo[700],
        highlightColor: Colors.indigo[700],
        minWidth: 200.0,
        height: 45.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
    );
  }

  @override
  bool shouldPop = true;
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    return WillPopScope(
      onWillPop: () async {
        return shouldPop;
      },
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.all(15.0),
                alignment: Alignment.bottomLeft,
                child: Text(
                  mydata[0][i.toString()],
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: "Quando",
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 6,
                child: AbsorbPointer(
                  absorbing: disableAnswer,
                    child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        choicebutton('a'),
                        choicebutton('b'),
                        choicebutton('c'),
                        choicebutton('d'),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.topCenter,
                child: Center(
                  child: Text(
                    showtimer,
                    style: TextStyle(
                      fontSize: 35.0,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Times New Roman',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
