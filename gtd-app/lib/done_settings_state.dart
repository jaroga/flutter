import 'package:flutter/material.dart';
import 'package:gtd_app/done_settings.dart';
import 'package:gtd_domain/gtd_domain.dart';
import 'package:mow/mow.dart';

class DoneOptionsWidget extends MOWWidget<DoneSettings> {
  DoneOptionsWidget({required DoneSettings model}) : super(model: model);
  @override
  MOWState<DoneSettings, DoneOptionsWidget> createState() =>
      _DoneOptionsState();
}

class _DoneOptionsState extends MOWState<DoneSettings, DoneOptionsWidget> {
  late BuildContext? _ctxt;

  @override
  Widget build(BuildContext context) {
    _ctxt = context;

    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: ToggleButtons(
        children: [
          _button('Nothing'),
          _button('Grey out'),
          _button('Delete', destructive: true)
        ],
        isSelected: model.toList(),
        direction: Axis.vertical,
        onPressed: _tapHandler,
      ),
    );
  }

  void _tapHandler(int index) async {
    // cuala es la opción que quiero cambiar
    DoneOptions opt = DoneOptions.values[index];

    if (DoneSettings.shared[opt] == false) {
      DoneSettings.shared[opt] = true;
    } else {
      DoneSettings.shared[opt] = false;
    }

    if (opt == DoneOptions.delete) {
      final shouldDelete = await showDialog<bool>(
        barrierDismissible: false,
        context: _ctxt!,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Should all 'done' tasks be deleted?"),
            content: SingleChildScrollView(
              child: Text('De verdad verdadera quieres borrtar todo?'),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('No')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Yes'))
            ],
          );
        },
      );

      // ya se habrá completado el futuro y sabemso la repsuesta del usuario
      if (shouldDelete == true) {
        // LLamar a un método del Repo que borra todas las tareas marcadas como done
        // mandando uan sola notificacion.
        // => crea un método removeDone en el repo.
        TaskRepository.shared.removeAll();
      }
    }
  }

  Widget _button(String caption, {bool destructive = false}) {
    if (!destructive) {
      return Text(caption);
    } else {
      return Row(
        children: [
          Icon(
            Icons.dangerous,
            size: 14,
            color: Colors.deepOrange[900],
          ),
          Text(caption)
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      );
    }
  }
}
