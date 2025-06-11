part of 'common_toast_widget.dart';

class _ToastSuccessDownloadGameWidget extends StatelessWidget {
  final ToastSuccessDownloadGame model;
  final VoidCallback onRemoveNotification;
  final Function(String) onTap;

  const _ToastSuccessDownloadGameWidget({
    super.key,
    required this.model,
    required this.onRemoveNotification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          onRemoveNotification();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  model.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.gameName,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Игра завершила загрузку",
                      overflow: TextOverflow.ellipsis,
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
}
