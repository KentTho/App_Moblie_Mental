import { getAuth, GoogleAuthProvider, signInWithPopup, signInWithEmailAndPassword } from 'firebase/auth';
import { useNavigate } from 'react-router-dom';
import { firebaseApp } from '../firebase/firebase';
import { useState } from 'react';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const navigate = useNavigate();
  const auth = getAuth(firebaseApp);

  const loginWithGoogle = async () => {
    const provider = new GoogleAuthProvider();
    await signInWithPopup(auth, provider);
    navigate('/admin/dashboard');
  };

  const loginWithEmail = async (e: any) => {
    e.preventDefault();
    await signInWithEmailAndPassword(auth, email, password);
    navigate('/admin/dashboard');
  };

  return (
    <div className="p-4 max-w-md mx-auto">
      <h1 className="text-xl font-bold mb-4">Admin Login</h1>
      <form onSubmit={loginWithEmail} className="space-y-2">
        <input type="email" placeholder="Email" value={email} onChange={e => setEmail(e.target.value)} className="w-full p-2 border rounded" />
        <input type="password" placeholder="Password" value={password} onChange={e => setPassword(e.target.value)} className="w-full p-2 border rounded" />
        <button type="submit" className="w-full bg-blue-600 text-white p-2 rounded">Login with Email</button>
      </form>
      <hr className="my-4" />
      <button onClick={loginWithGoogle} className="w-full bg-red-500 text-white p-2 rounded">Login with Google</button>
    </div>
  );
}
