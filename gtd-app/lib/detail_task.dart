import 'package:flutter/material.dart';
import 'package:gtd_app/done_settings.dart';
import 'package:gtd_domain/gtd_domain.dart';
import 'package:mow/mow.dart';

class DetailTask extends MOWWidget<Task> {
  DetailTask({required Task model, Key? key}) : super(model: model, key: key);

  @override
  MOWState<Task, DetailTask> createState() => _DetailTaskState();
}

class _DetailTaskState extends MOWState<Task, DetailTask> {
  final _controller = TextEditingController();

  var isSelected = [false];
  late BuildContext? _ctxt;
  var msgText = "";

  @override
  Widget build(BuildContext context) {
    _ctxt = context;

    if (model.state == TaskState.toDo) {
      isSelected = [false];
      msgText = "Tarea pendiente";
    } else {
      isSelected = [true];
      msgText = "Tarea terminada";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail of Task'),
        leading: BackButton(onPressed: () => returnToCaller(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {});
              },
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Describe your task',
                labelText: 'Task:',
                border: OutlineInputBorder(),
                icon: Icon(Icons.task),
                suffixIcon: _iconButton(),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
            ToggleButtons(
              children: <Widget>[
                Icon(Icons.check)
              ],
              onPressed: (int index){
                setState(() {
                  isSelected[index] = !isSelected[index];

                  if (model.state == TaskState.toDo) {
                    model.state = TaskState.done;

                    if (DoneSettings.shared[DoneOptions.delete]) {
                      _alertDelete("Eliminar Tarea");
                    }
                  } else {
                    model.state = TaskState.toDo;
                  }
                });
              },
              isSelected: isSelected,
            ),
          ],
        ),
      ),
    );
  }

  IconButton? _iconButton() {
    IconButton? ic;

    if (_controller.text.isEmpty) {
      ic = null;
    } else {
      ic = IconButton(
          onPressed: () {
            setState(() {
              _controller.clear();
            });
          },
          icon: Icon(Icons.clear));
    }

    return ic;
  }

  // Ciclo de vida
  @override
  void initState() {
    super.initState();

    // le meto en el controlador el valor inicial
    _controller.text = model.description;
    // Empezamos a observar el controlador para ir guardando cambios en la task

    _controller.addListener(_updateModel);
  }

  void _updateModel() {
    model.description = _controller.text;
    print(model);
  }

  @override
  void dispose() {
    // Nos damos de baja de las observaciones del controlador y lo destruimos
    _controller.removeListener(_updateModel);
    _controller.dispose();
    super.dispose();
  }

  void returnToCaller(BuildContext context) {
    Navigator.of(context).pop<Task?>(model);
  }


  void _alertDelete(String msg) async {
    final shouldDelete = await showDialog<bool>(
      barrierDismissible: false,
      context: _ctxt!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(msg),
          content: const SingleChildScrollView(
            child: Text('Estas seguro de que quieres eliminar la tarea?'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'No',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Si',
              ),
            ),
          ],
        );
      },
    );
    if (shouldDelete == true) {
      TaskRepository.shared.remove(model);
      Navigator.pop(context);
    }
  }
}