import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:simo_v_7_0_1/providers/provider_two.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:simo_v_7_0_1/screens/admin_dash_board.dart';

import 'package:simo_v_7_0_1/uploadingImagesAndproducts.dart';
import 'package:simo_v_7_0_1/widgets_utilities/multi_used_widgets.dart';
import 'package:simo_v_7_0_1/widgets_utilities/pop_up_menu_widget.dart';
import 'package:simo_v_7_0_1/widgets_utilities/spalsh_screen_widget.dart';
import 'package:simo_v_7_0_1/widgets_utilities/splash_screen_simple.dart';

class AdminAddProduct extends StatefulWidget {
  static const String id = '/HomeForUser';

  @override
  _AdminAddProductState createState() => _AdminAddProductState();
}

class _AdminAddProductState extends State<AdminAddProduct> {
  final scaffoldKeyUnique = GlobalKey<ScaffoldState>();

//ImagePicker
  File? imageFile;

  void pickupImage(ImageSource source) async {
    try {
      final imageFile = await ImagePicker().pickImage(source: source);

      if (imageFile == null) return;
      final imageTemporary = File(imageFile.path);
      setState(() {
        this.imageFile = imageTemporary;
      });
    } on PlatformException catch (e) {
      print('failed to pick up the image :$e');
    }
  }

  //Sheet function
  void showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: new Icon(Icons.photo_camera_outlined),
                title: new Text('Camera'),
                onTap: () {
                  pickupImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: new Icon(Icons.photo_library_outlined),
                title: new Text('Galeria'),
                onTap: () {
                  pickupImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Widget buildImageContainer() {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
              width: 120,
              height: 120,
              child: imageFile != null
                  ? ClipOval(
                      child: Image.file(
                        imageFile!,
                        fit: BoxFit.fill,
                      ),
                    )
                  : ClipRRect(
                      child: Image.asset('assets/iconPlaceholder12.png',
                          fit: BoxFit.fill),
                    )),
        ),
        GestureDetector(
          onTap: () {
            showPicker(context);
          },
          child: ClipOval(
              child: Container(
                  width: 40,
                  height: 40,
                  color: Colors.green,
                  child: Image.asset('assets/edit.png', fit: BoxFit.fill))),
        ),
      ],
    );
  }

  List taxTypesList = ['IVA', 'Impoconsumo', 'Exento'];
  List yesNoList = [' SI ', ' NO '];
  double discountinPercentage = 0;
  double Taxvalue = 0;
  double price_with_no_tax = 0;
  final _formKey = GlobalKey<FormState>();
  String? selectedCategory;
  String? selectedDiscuento;
  String? selectedTaxType;
  String? nombre;
  String? marca;
  String? contenido;
  String? typo_impuesto;
  String? porciento_impuesto;
  String? precio_ahora;
  String? hay_descuento;
  String? precio_anterior;
  String? descripcion;
  final _formKeyAddProduct = GlobalKey<FormState>();

  String? categoryvalue;
  String messageCategory = '';


  void showTextField(context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Anadir una categoria nueva'),
            content: TextField(
              autofocus: true,
              onChanged: (value) {
                categoryvalue = value;
              },
            ),
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    if (categoryvalue != null) {
                      messageCategory =
                          await ProductUploadingAndDispalyingFunctions()
                              .addNewcategory(categoryvalue!);
                      showMessage(context, messageCategory);
                      context.read<ProviderTwo>().initialValues();
                      await context.read<ProviderTwo>().bringproductos();
                    } else {
                      messageCategory = 'El texto es vacio .Intenta de nuevo';
                      showMessage(context, messageCategory);
                    }
                  },
                  child: Text('enviar')),
              ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  child: Text('cancel'))
            ],
          );
        });
  }

  void showMessage(context, String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(message),
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        AdminAddProduct.id, (Route<dynamic> route) => false);
                    context.read<ProviderTwo>().initialValues();
                    await context.read<ProviderTwo>().bringproductos();
                  },
                  child: Text('Ok')),
            ],
          );
        });
  }

  bool loading = true;

  @override
  Widget build(BuildContext context) {
    context.read<ProviderTwo>().bringproductos();
    return loading == false
        ? SplashScreen()
        : Scaffold(
           
            body: SafeArea(
              child: Column(
                children: [

                  PopUpMenuWidget(putArrow: true,

                    callbackArrow: (){
                      Navigator.of(context).pop();},
                    voidCallbackCart: (){
                      Navigator.of(context).pushNamed(AdminDashBoard.id);
                    },),



                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context.read<ProviderTwo>().initialValues();
                        await context.read<ProviderTwo>().bringproductos();
                      },
                      child: Consumer<ProviderTwo>(builder: (context, value, child) {
                        return value.map.isEmpty && !value.error
                            ? Center(child: CircularProgressIndicator())
                            : value.error
                                ? Text('OPs Something went wrong ${value.errorMessage}')
                                : Form(
                                    key: _formKeyAddProduct,
                                    child: ListView(
                                      children: [
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            buildImageContainer(),
                                            SizedBox(
                                              width: 4.0,
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.clear,
                                                size: 40.0,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  imageFile = null;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        UsedWidgets().buildDropDownButtonApiList(
                                            label: 'Escoger la manera del pago ',
                                            onChanged: (value) {
                                              setState(() {
                                                selectedCategory = value!;
                                              });
                                            },
                                            list: value.map['categorias']),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    showTextField(context);
                                                  },
                                                  icon: Icon(
                                                    Icons.add,
                                                    size: 40.0,
                                                    color: Colors.green,
                                                  )),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                'Anadir una categoria nueva',
                                                style: TextStyle(fontSize: 20.0),
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 6,
                                        ),
                                        UsedWidgets().buildTextFormWidgetForText(
                                          valueInitial: nombre,
                                          label: 'Nombre completo',
                                          onChanged: (value) {
                                            setState(() {
                                              nombre = value!;
                                            });
                                          },
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        UsedWidgets().buildTextFormWidgetForText(
                                          valueInitial: nombre,
                                          label: 'Marca',
                                          onChanged: (value) {
                                            setState(() {
                                              marca = value!;
                                            });
                                          },
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        UsedWidgets().buildTextFormWidgetForText(
                                          valueInitial: nombre,
                                          label: 'Contenido',
                                          onChanged: (value) {
                                            setState(() {
                                              contenido = value!;
                                            });
                                          },
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        UsedWidgets().buildDropDownButtonFixedList(
                                            label: 'Escoger el impuesto ',
                                            valueInitial: selectedTaxType,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedTaxType = value!;
                                              });
                                            },
                                            list: taxTypesList),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        UsedWidgets().buildTextFormWidgetForText(
                                          valueInitial: porciento_impuesto,
                                          label: 'Porciento de impuesto',
                                          onChanged: (value) {
                                            setState(() {
                                              porciento_impuesto = value!;
                                            });
                                          },
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        UsedWidgets().buildTextFormWidgetForText(
                                          valueInitial: precio_ahora,
                                          label: 'Precio',
                                          onChanged: (value) {
                                            setState(() {
                                              precio_ahora = value!;
                                            });
                                          },
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        UsedWidgets().buildTextFormWidgetForText(
                                          valueInitial: precio_anterior,
                                          label: 'Precio antes',
                                          onChanged: (value) {
                                            setState(() {
                                              precio_anterior = value!;
                                            });
                                          },
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        UsedWidgets().buildTextFormWidgetForText(
                                          valueInitial: descripcion,
                                          label: 'Descripcion',
                                          onChanged: (value) {
                                            setState(() {
                                              descripcion = value!;
                                            });
                                          },
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            if (_formKeyAddProduct.currentState!
                                                .validate()) {
                                              _formKeyAddProduct.currentState!.save();

                                              setState(() {
                                                loading == true;
                                              });

                                              calculationDiscountAndtaxes();

                                              if (imageFile != null) {
                                                String message =
                                                    await ProductUploadingAndDispalyingFunctions()
                                                        .uploadANewProductWithAnImage(
                                                  imageFile!,
                                                  selectedCategory == null
                                                      ? ''
                                                      : selectedCategory!,
                                                  nombre == null ? '' : nombre!,
                                                  marca == null ? '' : marca!,
                                                  contenido == null ? '' : contenido!,
                                                  selectedTaxType == null
                                                      ? ''
                                                      : selectedTaxType!,
                                                  porciento_impuesto == null
                                                      ? ''
                                                      : porciento_impuesto!,
                                                  Taxvalue.toString(),
                                                  precio_ahora == null
                                                      ? ''
                                                      : precio_ahora!,
                                                  price_with_no_tax.toString(),
                                                  selectedDiscuento == null
                                                      ? 'no'
                                                      : selectedDiscuento!,
                                                  precio_anterior == null
                                                      ? ''
                                                      : precio_anterior!,
                                                  discountinPercentage.toString(),
                                                  descripcion == null
                                                      ? ''
                                                      : descripcion!,
                                                );
                                                showstuff(context, message);
                                              } else {
                                                String message =
                                                    await ProductUploadingAndDispalyingFunctions()
                                                        .uploadANewProductWithoutImage(
                                                  selectedCategory == null
                                                      ? ''
                                                      : selectedCategory!,
                                                  nombre == null ? '' : nombre!,
                                                  marca == null ? '' : marca!,
                                                  contenido == null ? '' : contenido!,
                                                  selectedTaxType == null
                                                      ? ''
                                                      : selectedTaxType!,
                                                  porciento_impuesto == null
                                                      ? ''
                                                      : porciento_impuesto!,
                                                  Taxvalue.toString(),
                                                  precio_ahora == null
                                                      ? ''
                                                      : precio_ahora!,
                                                  price_with_no_tax.toString(),
                                                  selectedDiscuento == null
                                                      ? 'no'
                                                      : selectedDiscuento!,
                                                  precio_anterior == null
                                                      ? ''
                                                      : precio_anterior!,
                                                  discountinPercentage.toString(),
                                                  descripcion == null
                                                      ? ''
                                                      : descripcion!,
                                                );
                                                Navigator.of(context)
                                                    .pushNamedAndRemoveUntil(
                                                        AdminAddProduct.id,
                                                        (Route<dynamic> route) =>
                                                            false);

                                                setState(() {
                                                  loading == false;
                                                });

                                                showstuff(context, message);
                                              }
                                            }
                                          },
                                          child: Text('Enviar '),
                                        ),
                                      ],
                                    ),
                                  );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

// calculating the percentage of descount
  double calculateDiscount(precioAhora, precioAnterior) {
    return ((precioAnterior - precioAhora) / precioAnterior) * 100;
  }

// calculating the value of the tax in currency
  double value_of_tax(precioAhora, percentageOfTax) {
    return precioAhora * (percentageOfTax / 100);
  }

  // calculating the value of price without tax added in currency
  double value_price_with_no_tax(
      precioAhora, resultOfFunctionvalueOfTaxInCurrency) {
    return precioAhora - resultOfFunctionvalueOfTaxInCurrency;
  }

  void calculationDiscountAndtaxes() {
    discountinPercentage = 0;
    if (double.parse('$precio_ahora') > 0 &&
        double.parse('$precio_anterior') > 0 &&
        double.parse('$precio_ahora') < double.parse('$precio_anterior')) {
      discountinPercentage = calculateDiscount(
          double.parse('$precio_ahora'), double.parse('$precio_anterior'));
    } else {
      discountinPercentage = 0;
    }
    print(
        'discountInPercentage ====================================$discountinPercentage %');

    Taxvalue = 0;
    if (double.parse('$precio_ahora') > 0 &&
        double.parse('$precio_ahora') != null &&
        double.parse('$porciento_impuesto') > 0 &&
        double.parse('$porciento_impuesto') != null &&
        double.parse('$porciento_impuesto') < 900) {
      Taxvalue = value_of_tax(
          double.parse('$precio_ahora'), double.parse('$porciento_impuesto'));
    } else {
      Taxvalue = 0;
    }
    print('Taxvalue ====================================$Taxvalue');

    price_with_no_tax = 0;
    if (double.parse('$precio_ahora') > 0 &&
        double.parse('$porciento_impuesto') > 0 &&
        double.parse('$precio_ahora') != null) {
      price_with_no_tax =
          value_price_with_no_tax(double.parse('$precio_ahora'), Taxvalue);
    } else {
      price_with_no_tax = 0;
    }
    print(
        'price_with_no_tax ====================================$price_with_no_tax');
  }

  //notification alert widget
  void showstuff(context, String mynotification) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Notification'),
            content: Text(mynotification),
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    // Navigator.of(context).pushNamedAndRemoveUntil(DisplayProductsToBeEdited.id, (Route<dynamic> route) => false);
                    // context.read<ProviderTwo>().initialValues();
                    // await context.read<ProviderTwo>().bringproductos();
                  },
                  child: Text('Ok'))
            ],
          );
        });
  }
}
