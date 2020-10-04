import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';



void main() {
  runApp(MaterialApp(
    title: 'Simple Interest Calculator App',
    home: FormFlutter(),
  ));
}

class FormFlutter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FormFlutterState();
  }
}

class _FormFlutterState extends State<FormFlutter> {
  var _currencies = ['Rupees','Dollars','Pounds','Pesos'];
  final _minimumPadding = 5.0;
  //variables tensorflow
  File _image;
  final picker = ImagePicker();
  List _output;
  bool _state = false;

  @override
  void initState() {
    loadModel();
    super.initState();
  }

  //funtions tensorflow
  getImage()async{
    final pickedFile = await picker.getImage(source: ImageSource.gallery); //Select gellery webcam
    setState(() {
      if(pickedFile != null){
        _image= File(pickedFile.path);
        classifyImage(pickedFile);
      }else {
        print('No se encontro la imagen');
      }
    });
  }

  //funcion cargar modelo de tensorflow
  loadModel() async{
    await Tflite.loadModel(
      model: 'assets/model_unquant.tflite',
      labels: 'assets/labels.txt'
    );
  }

  //Funcion Clasificar
  classifyImage(image) async{
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5
    );

    setState(() {
      _output = output;
      _state = true;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Example Flutter TensorFlow')
      ),
      body: Container(
        margin: EdgeInsets.all(_minimumPadding * 2),
        child: Column(
          children: <Widget>[
            getImageAsset(),
            Padding(padding: EdgeInsets.only(top: _minimumPadding, bottom: _minimumPadding),
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Principal',
                hintText: 'Enter Principal e.g. 12000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0)
                )
              ),
            ))
            ,
            Padding(padding: EdgeInsets.only(top: _minimumPadding, bottom: _minimumPadding),
                child:TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Rate of interest',
                  hintText: 'In percent',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)
                  )
                ),
              )
            ),
            Padding(
              padding: EdgeInsets.only(top: _minimumPadding, bottom: _minimumPadding),
              child: Row(
              children: <Widget>[
                Expanded( child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Time',
                    hintText: 'Time in years',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)
                    )
                  ),
                )),
                Expanded( child: DropdownButton<String>(
                  items: _currencies.map((String value) => DropdownMenuItem<String>(value:value, child: Text(value))).toList(),
                  onChanged: (String newValueSelected) {

                  },
                  value: 'Pesos',
                )),
              ],
            )),
            Padding(
              padding: EdgeInsets.only(top: _minimumPadding, bottom: _minimumPadding),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _state == false? Container(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    ):
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: <Widget>[
                          _image == null ?
                            Container():
                            Image.file(_image),
                          SizedBox(height: 30),
                          _output != null ?
                            Text(
                              "${_output[0]['label']}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.0
                              ),
                            ):
                            Container()
                        ],
                      ),
                    )
                  )
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
            getImage();
        },
        child: Icon(Icons.image),
      ),
    );
  }

  Widget getImageAsset() {
    AssetImage assetImage = AssetImage('images/img_home.png');
    Image image = Image(
      image: assetImage,
      width: 125,
      height: 125,
    );

    return Container(
      child: image,
      margin: EdgeInsets.all(_minimumPadding * 10),
    );
  }
}