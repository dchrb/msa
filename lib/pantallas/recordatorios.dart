// lib/pantallas/recordatorios.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:msa/models/recordatorio.dart';
import 'package:msa/services/notification_service.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PantallaRecordatorios extends StatefulWidget {
  const PantallaRecordatorios({super.key});

  @override
  State<PantallaRecordatorios> createState() => _PantallaRecordatoriosState();
}

class _PantallaRecordatoriosState extends State<PantallaRecordatorios> {
  late Box<Recordatorio> _recordatorioBox;

  @override
  void initState() {
    super.initState();
    _recordatorioBox = Hive.box<Recordatorio>('recordatoriosBox');
  }

  String _formatearHora(TimeOfDay hora) {
    final hour = hora.hourOfPeriod == 0 ? 12 : hora.hourOfPeriod;
    final period = hora.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:${hora.minute.toString().padLeft(2, '0')} $period";
  }

  Future<TimeOfDay?> mostrarTimePickerAmPm(BuildContext context,
      {TimeOfDay? horaInicial}) async {
    int selectedHour = horaInicial?.hourOfPeriod ?? 12;
    int selectedMinute = horaInicial?.minute ?? 0;
    DayPeriod selectedPeriod = horaInicial?.period ?? DayPeriod.am;

    return showDialog<TimeOfDay>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Seleccionar Hora (AM/PM)'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<int>(
                    value: selectedHour,
                    items: List.generate(12, (index) => index + 1)
                        .map((h) => DropdownMenuItem(value: h, child: Text(h.toString())))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => selectedHour = value);
                    },
                  ),
                  const Text(" : "),
                  DropdownButton<int>(
                    value: selectedMinute,
                    items: List.generate(60, (index) => index)
                        .map((m) => DropdownMenuItem(
                            value: m, child: Text(m.toString().padLeft(2, '0'))))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => selectedMinute = value);
                    },
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<DayPeriod>(
                    value: selectedPeriod,
                    items: const [
                      DropdownMenuItem(value: DayPeriod.am, child: Text('AM')),
                      DropdownMenuItem(value: DayPeriod.pm, child: Text('PM')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => selectedPeriod = value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    final hour = selectedPeriod == DayPeriod.pm
                        ? (selectedHour % 12) + 12
                        : selectedHour % 12;
                    Navigator.of(ctx).pop(TimeOfDay(hour: hour, minute: selectedMinute));
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarNotificacionDePrueba() {
    NotificationService().showTestNotification();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Recordatorio>>(
      valueListenable: _recordatorioBox.listenable(),
      builder: (context, box, _) {
        final recordatorios = box.values.toList();
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Mis Recordatorios'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: recordatorios.isEmpty
              ? const Center(
                  child: Text(
                    'No tienes recordatorios.\n¡Añade uno con el botón +!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: recordatorios.length,
                  itemBuilder: (context, index) {
                    final recordatorio = recordatorios[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          recordatorio.mensaje,
                          style: TextStyle(
                            fontSize: 18,
                            decoration: !recordatorio.activado ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text(
                          _formatearHora(recordatorio.timeOfDay),
                          style: TextStyle(
                            decoration: !recordatorio.activado ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        trailing: Switch(
                          value: recordatorio.activado,
                          onChanged: (value) {
                            recordatorio.activado = value;
                            recordatorio.save();
                            if (value) {
                              NotificationService().programarRecordatorio(recordatorio);
                            } else {
                              NotificationService().cancelarRecordatorio(recordatorio.id.hashCode);
                            }
                          },
                        ),
                        onTap: () {
                          _mostrarDialogoEditar(recordatorio);
                        },
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('¿Eliminar Recordatorio?'),
                              content: const Text('Esta acción no se puede deshacer.'),
                              actions: [
                                TextButton(
                                  child: const Text('Cancelar'),
                                  onPressed: () => Navigator.of(ctx).pop(),
                                ),
                                TextButton(
                                  child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                  onPressed: () {
                                    NotificationService().cancelarRecordatorio(recordatorio.id.hashCode);
                                    recordatorio.delete();
                                    Navigator.of(ctx).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: _mostrarDialogoAnadir,
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _mostrarNotificacionDePrueba,
              icon: const Icon(Icons.notifications_active),
              label: const Text('Probar Notificación'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        );
      },
    );
  }

  void _mostrarDialogoAnadir() async {
    TimeOfDay horaSeleccionada = TimeOfDay.now();
    final mensajeController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo Recordatorio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: mensajeController,
              decoration: const InputDecoration(labelText: 'Mensaje'),
              autofocus: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final TimeOfDay? horaElegida =
                    await mostrarTimePickerAmPm(context, horaInicial: horaSeleccionada);
                if (horaElegida != null) {
                  horaSeleccionada = horaElegida;
                }
              },
              child: const Text('Seleccionar Hora'),
            ),
          ],
        ),
      actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Guardar'),
            onPressed: () {
              if (mensajeController.text.isNotEmpty) {
                final nuevoRecordatorio = Recordatorio(
                  id: const Uuid().v4(),
                  hora: horaSeleccionada.hour,
                  minuto: horaSeleccionada.minute,
                  mensaje: mensajeController.text,
                  activado: true,
                );
                _recordatorioBox.put(nuevoRecordatorio.id, nuevoRecordatorio);
                NotificationService().programarRecordatorio(nuevoRecordatorio);
                Navigator.of(ctx).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEditar(Recordatorio recordatorio) async {
    TimeOfDay horaSeleccionada = recordatorio.timeOfDay;
    final mensajeController = TextEditingController(text: recordatorio.mensaje);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Recordatorio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: mensajeController,
              decoration: const InputDecoration(labelText: 'Mensaje'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final TimeOfDay? horaElegida =
                    await mostrarTimePickerAmPm(context, horaInicial: horaSeleccionada);
                if (horaElegida != null) {
                  horaSeleccionada = horaElegida;
                }
              },
              child: const Text('Seleccionar Hora'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Guardar'),
            onPressed: () {
              recordatorio.hora = horaSeleccionada.hour;
              recordatorio.minuto = horaSeleccionada.minute;
              recordatorio.mensaje = mensajeController.text;
              recordatorio.save();
              NotificationService().cancelarRecordatorio(recordatorio.id.hashCode);
              NotificationService().programarRecordatorio(recordatorio);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}