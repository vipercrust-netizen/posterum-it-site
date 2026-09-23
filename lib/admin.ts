import bcrypt from "bcryptjs";import {prisma} from "@/lib/prisma";
export async function ensureInitialAdmin(){if(await prisma.admin.count())return;const login=process.env.ADMIN_LOGIN;const password=process.env.ADMIN_PASSWORD;if(!login||!password)return;await prisma.admin.create({data:{login,passwordHash:await bcrypt.hash(password,12)}})}
