# SME Advisor — Flutter client

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- Running backend (`../backend` Docker Compose or local `uvicorn`)

## First-time setup

If this folder does not yet contain platform projects (`android/`, `ios/`, …), generate them once:

```bash
flutter create .
```

Then:

```bash
flutter pub get
flutter run
```

## Connecting to the API

`lib/utils/constants.dart` resolves the base URL:

- Android emulator → `http://10.0.2.2:8000`
- Other platforms → `http://127.0.0.1:8000`
- Override: `flutter run --dart-define=API_BASE=http://192.168.0.10:8000`

## CSV upload format

Columns (flexible names, case-insensitive):

- **date** — `date`, `txn_date`, or `transaction_date`
- **amount** — `amount` or `amount_rm`
- **category** — required
- **description** — optional
- **is_expense** — optional (`true` / `false`); defaults to expenses

Bundled asset: `assets/sample_transactions.csv` (matches SME 1 after seed).

## Screens

| Tab | Purpose |
|-----|---------|
| Health | Financial overview, health gauge, KPI cards, revenue vs expense chart |
| Simulate | BNPL purchase simulator + modal result with SHAP-style factors |
| AI Advisor | Last recommendation summary |
| Grants | Government / agency funding explorer with filters |
| Performance | Model metrics + prediction history (tap for detail) |

Drawer: quick SME ID (1–3) and **Upload CSV**.
