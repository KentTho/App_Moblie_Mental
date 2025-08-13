'use client'

import { createContext, useContext, useEffect, useState } from 'react'
import { User, onAuthStateChanged, signOut as firebaseSignOut } from 'firebase/auth'
import { auth } from '@/lib/firebase'
import { useRouter } from 'next/navigation'

interface UserData {
  id: number
  email: string
  full_name: string
  role: string
  is_verified: boolean
  firebase_uid: string
}

interface AuthContextType {
  user: User | null
  userData: UserData | null
  loading: boolean
  isAdmin: boolean
  signOut: () => Promise<void>
}

const AuthContext = createContext<AuthContextType | null>(null)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [userData, setUserData] = useState<UserData | null>(null)
  const [loading, setLoading] = useState(true)
  const [isAdmin, setIsAdmin] = useState(false)
  const router = useRouter()

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      setLoading(true)
      
      if (firebaseUser) {
        setUser(firebaseUser)
        
        try {
          // Get the Firebase ID token
          const token = await firebaseUser.getIdToken()
          
          // Make API call to get user data
          const response = await fetch(`${process.env.NEXT_PUBLIC_API_BASE_URL}/user/firebase/${firebaseUser.uid}`, {
            headers: {
              'Authorization': `Bearer ${token}`,
              'Content-Type': 'application/json',
            },
          })

          if (response.ok) {
            const data = await response.json()
            setUserData(data)
            setIsAdmin(data.role === 'admin')
          } else {
            console.error('Failed to fetch user data:', response.statusText)
            // If API call fails, you might want to sign out the user
            await firebaseSignOut(auth)
          }
        } catch (error) {
          console.error('Error fetching user data:', error)
          // Handle the error appropriately
          await firebaseSignOut(auth)
        }
      } else {
        setUser(null)
        setUserData(null)
        setIsAdmin(false)
      }
      
      setLoading(false)
    })

    return () => unsubscribe()
  }, [])

  const signOut = async () => {
    await firebaseSignOut(auth)
    setUser(null)
    setUserData(null)
    setIsAdmin(false)
    router.push('/login')
  }

  return (
    <AuthContext.Provider value={{ user, userData, loading, isAdmin, signOut }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}
