import { getAuth, GoogleAuthProvider, signInWithPopup, signInWithEmailAndPassword } from 'firebase/auth';
import { useNavigate } from 'react-router-dom';
import { firebaseApp } from '../firebase/firebase';
import { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { FcGoogle } from 'react-icons/fc';
import { FiMail, FiLock } from 'react-icons/fi';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const navigate = useNavigate();
  const auth = getAuth(firebaseApp);
  const { setUser, setIsAdmin } = useAuth();

  const fetchUserRole = async (uid: string) => {
    try {
      const res = await fetch(`http://127.0.0.1:8000/user/firebase/${uid}`);
      if (!res.ok) throw new Error('Không thể lấy thông tin người dùng');
      const data = await res.json();
      return data.role;
    } catch (error) {
      console.error('Lỗi khi lấy role:', error);
      return null;
    }
  };

  const loginWithGoogle = async () => {
    try {
      const provider = new GoogleAuthProvider();
      const result = await signInWithPopup(auth, provider);
      const uid = result.user.uid;

      const role = await fetchUserRole(uid);
      if (role === 'admin') {
        setUser(result.user);
        setIsAdmin(true);
        navigate('/admin/dashboard');
      } else {
        alert('Bạn không có quyền truy cập admin');
      }
    } catch (error) {
      console.error('Đăng nhập Google thất bại:', error);
    }
  };

  const loginWithEmail = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const result = await signInWithEmailAndPassword(auth, email, password);
      const uid = result.user.uid;

      const role = await fetchUserRole(uid);
      if (role === 'admin') {
        setUser(result.user);
        setIsAdmin(true);
        navigate('/admin/dashboard');
      } else {
        setIsAdmin(false);
        alert('Bạn không có quyền truy cập admin');
      }
    } catch (error) {
      console.error('Đăng nhập Email thất bại:', error);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-500 via-purple-500 to-pink-500 p-4">
      <div className="bg-white rounded-2xl shadow-xl w-full max-w-md p-8">
        <h1 className="text-2xl font-bold text-center mb-6 text-gray-800">Admin Panel Login</h1>

        <form onSubmit={loginWithEmail} className="space-y-4">
          <div className="flex items-center border rounded-lg px-3 py-2 focus-within:ring-2 ring-blue-400">
            <FiMail className="text-gray-500 mr-2" />
            <input
              type="email"
              placeholder="Email"
              value={email}
              onChange={e => setEmail(e.target.value)}
              className="w-full outline-none"
              required
            />
          </div>

          <div className="flex items-center border rounded-lg px-3 py-2 focus-within:ring-2 ring-blue-400">
            <FiLock className="text-gray-500 mr-2" />
            <input
              type="password"
              placeholder="Password"
              value={password}
              onChange={e => setPassword(e.target.value)}
              className="w-full outline-none"
              required
            />
          </div>

          <button
            type="submit"
            className="w-full bg-blue-600 hover:bg-blue-700 text-white py-2 rounded-lg font-semibold transition duration-200"
          >
            Đăng nhập bằng Email
          </button>
        </form>

        <div className="my-6 flex items-center">
          <hr className="flex-1 border-gray-300" />
          <span className="px-3 text-gray-500 text-sm">Hoặc</span>
          <hr className="flex-1 border-gray-300" />
        </div>

        <button
          onClick={loginWithGoogle}
          className="w-full flex items-center justify-center gap-2 border border-gray-300 rounded-lg py-2 hover:bg-gray-50 transition duration-200"
        >
          <FcGoogle size={20} /> Đăng nhập với Google
        </button>
      </div>
    </div>
  );
}
