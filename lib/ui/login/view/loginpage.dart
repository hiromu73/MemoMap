import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:memoplace/ui/login/view_model/loginuser.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController emailController = useTextEditingController();
    final TextEditingController passwordController = useTextEditingController();
    final FocusNode emailFocusNode = useFocusNode();
    final FocusNode passwordFocusNode = useFocusNode();
    final email = useState<String>("");
    final password = useState<String>("");
    final infoText = useState<String>("");
    Color baseColor = Colors.orange.shade100;
    return Scaffold(
      body: InkWell(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                // メールアドレス入力
                Container(
                    color: baseColor,
                    child: Center(
                        child: Container(
                      height: 55,
                      width: 350,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(
                                -3, -3), // changes position of shadow
                          ),
                          const BoxShadow(
                            color: Colors.white,
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(3, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: TextFormField(
                        focusNode: emailFocusNode,
                        controller: emailController,
                        maxLength: null,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          fillColor: Colors.orange.shade100,
                          filled: true,
                          isDense: true,
                          hintText: "メールアドレス",
                          hintStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w100),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        textAlign: TextAlign.start,
                        onChanged: (String value) async {
                          email.value = value;
                        },
                      ),
                    ))),
                const SizedBox(height: 30),
                // パスワード入力
                Container(
                    color: baseColor,
                    child: Center(
                        child: Container(
                      height: 55,
                      width: 350,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(
                                -3, -3), // changes position of shadow
                          ),
                          const BoxShadow(
                            color: Colors.white,
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(3, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: TextFormField(
                        focusNode: passwordFocusNode,
                        controller: passwordController,
                        maxLength: null,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          fillColor: Colors.orange.shade100,
                          filled: true,
                          isDense: true,
                          hintText: "パスワード",
                          hintStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w100),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        textAlign: TextAlign.left,
                        onChanged: (String value) async {
                          password.value = value;
                        },
                      ),
                    ))),

                Container(
                  padding: const EdgeInsets.all(20),
                  // メッセージ表示
                  child: Text(infoText.value),
                ),
                // ユーザー登録ボタン
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                        color: baseColor,
                        child: Center(
                            child: Container(
                          height: 40,
                          width: 100,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(
                                    -3, -3), // changes position of shadow
                              ),
                              const BoxShadow(
                                color: Colors.white,
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(3, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.orange.shade100,
                              ),
                              child: const Text('登録'),
                              onPressed: () async {
                                try {
                                  // メール/パスワードでユーザー登録
                                  final FirebaseAuth auth =
                                      FirebaseAuth.instance;
                                  final result =
                                      await auth.createUserWithEmailAndPassword(
                                    email: email.value,
                                    password: password.value,
                                  );
                                  await ref
                                      .read(loginUserProvider.notifier)
                                      .getLoginUser(result.user!);
                                  if (context.mounted) {
                                    await context.push('/memolist');
                                  }
                                } catch (e) {
                                  infoText.value =
                                      "ログインに失敗しました：${e.toString()}";
                                }
                              }),
                        ))),
                    Container(
                        color: baseColor,
                        child: Center(
                            child: Container(
                          height: 40,
                          width: 100,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(-3, -3),
                              ),
                              const BoxShadow(
                                color: Colors.white,
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(3, 3),
                              ),
                            ],
                          ),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.orange.shade100,
                            ),
                            child: const Text('ログイン'),
                            onPressed: () async {
                              try {
                                final FirebaseAuth auth = FirebaseAuth.instance;
                                final result =
                                    await auth.signInWithEmailAndPassword(
                                  email: email.value,
                                  password: password.value,
                                );
                                await ref
                                    .read(loginUserProvider.notifier)
                                    .getLoginUser(result.user!);
                                if (context.mounted) {
                                  await context.push('/memolist');
                                }
                              } catch (e) {
                                // ユーザー登録に失敗した場合
                                infoText.value = "ログインに失敗しました：${e.toString()}";
                              }
                            },
                          ),
                        ))),

                    // ElevatedButton(
                    //   child: const Text('登録'),
                    //   onPressed: () async {
                    //     try {
                    //       // メール/パスワードでユーザー登録
                    //       // final FirebaseAuth auth = FirebaseAuth.instance;
                    //       // await auth.createUserWithEmailAndPassword(
                    //       //   email: email,
                    //       //   password: password,
                    //       // );
                    //       // ユーザー登録に成功した場合
                    //       // チャット画面に遷移＋ログイン画面を破棄
                    //       if (context.mounted) {
                    //         print("b");
                    //         await context.push('/memolist');
                    //       }

                    //       print("a");
                    //     } catch (e) {
                    //       // ユーザー登録に失敗した場合
                    //       print("c");
                    //     }
                    //   },
                    // ),
                    // ログインボタン
                    // ClayContainer(
                    //   color: baseColor,
                    //   child: ElevatedButton(
                    //     child: const Text('ログイン'),
                    //     onPressed: () async {
                    //       try {
                    //         // メール/パスワードでユーザー登録
                    //         final FirebaseAuth auth = FirebaseAuth.instance;
                    //         await auth.createUserWithEmailAndPassword(
                    //           email: email,
                    //           password: password,
                    //         );
                    //         // ユーザー登録に成功した場合
                    //         // チャット画面に遷移＋ログイン画面を破棄
                    //         if (context.mounted) {
                    //           await context.push('/memolist');
                    //         }
                    //       } catch (e) {
                    //         // ユーザー登録に失敗した場合
                    //       }
                    //     },
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 20)
              ],
            ),
          ),
        ),
      ),
    );
  }
}