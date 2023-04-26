import 'dart:convert';
import 'package:http/http.dart' as http;

Future sendMail({
    required String email,
    required String subject,
    required String body,}
) async
{

  //final user = FirebaseAuth.instance.currentUser;
  final serviceId='service_4o3ltq5';
  final templateId='template_2g3zbzk';
  final userId='XzFRqVsgWkL3Xpv-K';
  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
  final response = await http.post(
    url,
    headers:
      {
        'Content-Type':'application/json',
      },
    body: json.encode({
      'service_id':serviceId,
      'template_id':templateId,
      'user_id':userId,
      'template_params':
          {
            'user_email':email,
            'user_message': body,
            'user_subject':subject,
          }
    }),
  );

}


