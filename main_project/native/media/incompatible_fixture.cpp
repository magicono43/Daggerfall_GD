// Deliberately valid Windows DLL with an incompatible media ABI. Test only.
extern "C" __declspec(dllexport) int native_fixture_only() { return 1; }
