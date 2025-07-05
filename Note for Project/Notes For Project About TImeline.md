Hiện tại bắt đầu:



05/07/2025:



* (**16h30): I fixed Auth** (Login and Register) about authentication gg and GitHub



* **(20h15)COntinous Note (Diary: Ghi chú nhật ký cảm xúc)**

\- Done Flutter (FE)

\- Begin BE and Database



* **(23h): I building FE connect note** 

-- Add file changenotifiers/notes\_provider.dart

-- Modifying emotion\_entry: 

" 

body: Consumer<NotesProvider>(

&nbsp;         builder: (context, NotesProvider, child) {

&nbsp;           return Padding(

&nbsp;             padding: const EdgeInsets.symmetric(horizontal: 16.0),

... 

"

-- Bug NoteProvider => Fixed

-- main too modified: 

"

void main() async {

&nbsp; WidgetsFlutterBinding.ensureInitialized();

&nbsp; try {

&nbsp;   await Firebase.initializeApp(

&nbsp;     options: DefaultFirebaseOptions.currentPlatform,

&nbsp;   );

&nbsp;   print('✅ Firebase initialized!');

&nbsp; } catch (e) {

&nbsp;   print('❌ Firebase init failed: $e');

&nbsp; }



&nbsp; runApp(

&nbsp;   ChangeNotifierProvider(

&nbsp;     create: (\_) => NotesProvider(),

&nbsp;     child: const MyApp(),

&nbsp;   ),

&nbsp; );

}

"



* End video Part 3: 26:05



https://chatgpt.com/c/68694918-450c-8010-9be1-4104a5bf84a9 (Lỗi NotesProvider trong Flutter)



https://chatgpt.com/c/685bc1ba-7d28-8010-9a9f-44fd9a777fe8 (Diary)



