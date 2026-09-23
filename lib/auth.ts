import {SignJWT,jwtVerify} from "jose";import {cookies} from "next/headers";
const COOKIE="posterum_admin";function key(){const s=process.env.SESSION_SECRET;if(!s)throw new Error("SESSION_SECRET is not configured");return new TextEncoder().encode(s)}
export async function createSession(adminId:number,login:string){const token=await new SignJWT({adminId,login}).setProtectedHeader({alg:"HS256"}).setIssuedAt().setExpirationTime("7d").sign(key());const c=await cookies();c.set(COOKIE,token,{httpOnly:true,sameSite:"lax",secure:process.env.NODE_ENV==="production",path:"/",maxAge:604800})}
export async function destroySession(){const c=await cookies();c.delete(COOKIE)}
export async function getSession(){try{const c=await cookies();const token=c.get(COOKIE)?.value;if(!token)return null;const {payload}=await jwtVerify(token,key());return payload as {adminId:number;login:string}}catch{return null}}
