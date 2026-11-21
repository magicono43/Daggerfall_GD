// Frozen binary identities. See dependencies.lock.json and notices/.
struct DependencyHash { const wchar_t *name; const char *sha256; };
static const DependencyHash dependency_hashes[] = {
    {L"avcodec-62.dll","b73de3e72de25186c921dcc2cc4399a9e3196b022e0309b9da9e53b0d170f5ca"},
    {L"avformat-62.dll","5e08b7c4073187ea172215d667d335885b604a724856a7bdf736378343bdb70d"},
    {L"avutil-60.dll","4fe6682eeac1cdfc8c699637bdd04cee8312d03f2d3794cb4436230dd14bddda"},
    {L"libfluidsynth-3.dll","a7c6d9945c32249614216aabc47b5a064d306dca81c54e26e4930d776cdecf3d"},
    {L"libglib-2.0-0.dll","0c3720b588874fc3c60f66b486c4172c4976c56b0b0f04908f730d7215c93400"},
    {L"libgobject-2.0-0.dll","28ca3fe5392dce2e8c48b6157baa9da31f88ebb7103dc2ce7feeca7d5a3b17ca"},
    {L"libgthread-2.0-0.dll","f49aabf9d780bcaae8f72870a2f2a6817e987efd115aaee6c9442d401ab4bb34"},
    {L"libinstpatch-2.dll","3f46c2a0151e1fff951b38797ae1e0c5e0a0b13826a4c2f1ba99fc253a26214b"},
    {L"libintl-8.dll","7cf5a705c825e082d8e7b57d113ebcba897a9421f465a7e43ad610b89a359b14"},
    {L"SDL3.dll","2dfe1c60557c3e054ddda61bf7f29fdfd462c10faddf04dc6864961f43960df6"},
    {L"sndfile.dll","4e3bd2de8e1485110eaebef8e1239471f73d608773831c323bf528e05645655e"},
    {L"swresample-6.dll","b4ff013d1baf6bd7f7fb0d823bc61e98b9ad5ce2409c79b16a25bcfd57ca1d87"},
    {L"swscale-9.dll","3d459670f04e73d878561c5a13dc67aa967dda8682bc21a872a45da11d21037a"},
};
