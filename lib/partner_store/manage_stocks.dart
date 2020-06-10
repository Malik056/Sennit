import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:sennit/main.dart';
import 'package:sennit/models/models.dart';

class ManageItemsRoute extends StatelessWidget {
  final String storeId = (Session.data['partnerStore'] as Store).storeId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('items')
            .where(
              'storeId',
              isEqualTo: storeId,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Unable To Fetch Data. Retrying .....",
                style: Theme.of(context).textTheme.headline5,
              ),
            );
          } else if (!snapshot.hasData) {
            return Text(
              'Couldn\'t Find Anything',
              style: Theme.of(context).textTheme.headline5,
            );
          } else if ((snapshot.data?.documents?.length ?? 0) > 0) {
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                StoreItem item =
                    StoreItem.fromMap(snapshot.data.documents[index].data);
                return Dismissible(
                  key: ObjectKey(item.itemId),
                  child: ItemWidget(
                    item: item,
                  ),
                  confirmDismiss: (direction) async {
                    bool result = await showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) {
                        return AlertDialog(
                          actions: <Widget>[
                            FlatButton(
                              child: Text('No'),
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                            ),
                            FlatButton(
                              child: Text('Yes'),
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                            ),
                          ],
                          title: Text('Delete'),
                          content: Text(
                            'Are you sure you want to Delete ${item.itemName}',
                          ),
                        );
                      },
                    );
                    return result ?? false;
                  },
                  onDismissed: (direction) async {
                    BotToast.showLoading();
                    final batch = Firestore.instance.batch();
                    Store store = Session.data['partnerStore'];
                    DocumentReference itemReference = Firestore.instance
                        .collection('items')
                        .document(item.itemId);
                    DocumentReference storeReference = Firestore.instance
                        .collection('stores')
                        .document(item.storeId);
                    batch.setData(
                      storeReference,
                      {
                        'items': FieldValue.arrayRemove(
                          [
                            item.itemId,
                          ],
                        ),
                      },
                      merge: true,
                    );
                    batch.delete(itemReference);
                    bool error = false;
                    await batch.commit().catchError((error) {
                      Utils.showSnackBarErrorUsingKey(
                          null, 'Something Went Wrong! Try Again');
                      error = true;
                    });
                    if (!error) {
                      List<Future<void>> requests = [];
                      item.storagePaths?.forEach((element) {
                        Future<void> request = FirebaseStorage.instance
                            .ref()
                            .child(element)
                            .delete();
                        requests.add(request);
                      });
                      for (var request in requests) {
                        await request;
                      }
                      store.items.removeWhere(
                        (element) => element == item.itemId,
                      );
                    }
                    BotToast.closeAllLoading();
                  },
                );
              },
            );
          } else {
            return Text(
              'No Item Found',
              style: Theme.of(context).textTheme.headline5,
            );
          }
        },
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  final StoreItem item;
  const ItemWidget({
    Key key,
    this.item,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            6.0,
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(4.0),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6.0),
                        // bottomLeft: Radius.circular(6.0),
                      ),
                    ),
                  ),
                  child: Image.network(
                    item.images[0],
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      GestureDetector(
                        child: Text(
                          item.itemName,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        onLongPress: () async {
                          String newName = await showDialogWithParam(
                            context,
                            item.itemName,
                            'Item Name',
                            TextInputType.text,
                            '',
                            24,
                            'Item Name',
                            (text) {
                              if (text?.isEmpty ?? true) {
                                return 'Invalid name';
                              } else {
                                return null;
                              }
                            },
                          );
                          if (newName == null) {
                            return;
                          }
                          Firestore.instance
                              .collection('items')
                              .document(item.itemId)
                              .setData(
                            {'itemName': newName},
                            merge: true,
                          );
                        },
                      ),
                      SizedBox(height: 2.0),
                      GestureDetector(
                        child: Text(
                          (item.description ?? '') == ''
                              ? 'No Description'
                              : item.description,
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                        onLongPress: () async {
                          String description = await showDialogWithParam(
                            context,
                            item.description,
                            'Description',
                            TextInputType.text,
                            '',
                            200,
                            'Enter Description',
                            (text) {
                              return null;
                            },
                            5,
                            5,
                          );
                          if (description == null) {
                            return;
                          }
                          Firestore.instance
                              .collection('items')
                              .document(item.itemId)
                              .setData(
                            {
                              'description': description,
                            },
                            merge: true,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 6.0,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    GestureDetector(
                      onLongPress: () async {
                        print('');
                        String newStock = await showDialogWithParam(
                          context,
                          '${item.remainingInStock ?? '0'}',
                          'Stock',
                          TextInputType.text,
                          '',
                          4,
                          'Update Number of Items in Stock',
                          (text) {
                            if (text?.isEmpty ?? true) {
                              return 'Field Cannot be Empty';
                            } else {
                              int stock = int.tryParse(text);
                              if (stock == null) {
                                return 'Please Enter a Valid Number';
                              }
                              return null;
                            }
                          },
                        );
                        if (newStock == null) {
                          return;
                        }
                        Firestore.instance
                            .collection('items')
                            .document(item.itemId)
                            .setData(
                          {
                            'remainingInStock': int.tryParse(newStock) ??
                                (item.remainingInStock ?? 0),
                          },
                          merge: true,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 10),
                        child: Text(
                          'In Stock: ${item?.remainingInStock ?? 0}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onLongPress: () async {
                        print('');
                        String price = await showDialogWithParam(
                          context,
                          '${item.price ?? 0}',
                          'Item Price',
                          TextInputType.text,
                          '',
                          4,
                          'Price',
                          (text) {
                            if (text?.isEmpty ?? true) {
                              return 'Field Cannot be Empty';
                            } else {
                              double price = double.tryParse(text);
                              if (price == null) {
                                return 'Please Enter a Valid Number';
                              }
                              return null;
                            }
                          },
                        );
                        if (price == null) {
                          return;
                        }
                        Firestore.instance
                            .collection('items')
                            .document(item.itemId)
                            .setData(
                          {
                            'price':
                                double.tryParse(price) ?? (item?.price ?? 0),
                          },
                          merge: true,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(4.0, 10, 4.0, 0),
                        child: Text(
                          'Price: ${item.price ?? 0}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> showDialogWithParam(
    BuildContext context,
    String oldValue,
    String title,
    TextInputType inputType,
    String suffix,
    int maxLength,
    String labelText,
    Function(String) validator, [
    int minLines = 1,
    int maxLines = 1,
  ]) async {
    TextEditingController controller = TextEditingController(
      text: oldValue,
    );
    controller.value = TextEditingValue(
        text: oldValue,
        selection: TextSelection(baseOffset: 0, extentOffset: oldValue.length));
    var formKey = GlobalKey<FormState>();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context, null),
          ),
          FlatButton(
              child: Text('Done'),
              onPressed: () {
                if (formKey.currentState.validate()) {
                  Navigator.pop(
                    context,
                    controller.value,
                  );
                }
              }),
        ],
        title: Text(title),
        content: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Form(
            key: formKey,
            child: TextFormField(
              focusNode: FocusNode()..requestFocus(),
              controller: controller,
              keyboardType: inputType,
              minLines: minLines,
              maxLines: maxLines,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: labelText,
                suffix: Text(suffix ?? ''),
              ),
              maxLength: maxLength,
              onEditingComplete: () {
                formKey.currentState.validate();
              },
              validator: validator,
            ),
          ),
        ),
      ),
    );
    return controller.text;
  }
}
