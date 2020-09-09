part of "helpers.dart";

mostrarLoading(BuildContext context) {
  final title = "Espere...";

  if(Platform.isIOS) {
    return showCupertinoDialog(
      context: context, 
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: CupertinoActivityIndicator(),
      )
    );
  } 

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: LinearProgressIndicator(),
    )
  );
}

mostrarAlerta(BuildContext context, String title, String message) {
  if(Platform.isIOS) {
    return showCupertinoDialog(
      context: context, 
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Ok"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      )
    );
  } 

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        MaterialButton(
          child: Text("Ok"),
          onPressed: () => Navigator.pop(context),
        )
      ],
    )
  );
}