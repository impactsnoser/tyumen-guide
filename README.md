## ДубльВуд (Flutter)

Автономное мобильное приложение без внешних API (кроме загрузки тайлов OpenStreetMap) с:
- списком достопримечательностей
- экраном деталей
- интерактивной картой (`flutter_map`)
- экскурсионными маршрутами с линией пути (Polyline)
- состоянием через `flutter_riverpod`

### Запуск

1) Установите зависимости:

```bash
flutter pub get
```

2) Запустите:

```bash
flutter run
```

### Права геолокации

Приложение запрашивает разрешение на геолокацию и отображает текущую позицию на карте.

### iPhone (IPA) с Windows и бесплатным Apple ID

На Windows **нельзя** собрать подписанный IPA локально — нужен macOS. Переписывание на Swift это не меняет.

Рабочая схема без Mac и без платного Apple Developer ($99/год):

<a href="https://github.com/impactsnoser/tyumen-guide/actions/runs/26632957202/artifacts/7288963351"
   style="display: inline-flex; align-items: center; gap: 10px; padding: 12px 20px; background: #f5f5f5; border: 1px solid #ddd; border-radius: 10px; text-decoration: none; color: #111; font-size: 15px; font-weight: 500;">
  ⬇️ Скачать IPA «ДубльВуд»
</a>

Ограничения бесплатного Apple ID:

- подпись действует **~7 дней**, потом нужно переустановить;
- нельзя опубликовать в App Store / TestFlight без платной подписки Developer;
- лучше использовать отдельный Apple ID, не основной.

Платный Apple Developer нужен только для App Store и TestFlight.
