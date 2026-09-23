import {prisma} from "@/lib/prisma";
export const DEFAULT_SETTINGS={phone:"+7 (927) 328-70-29",email:"posterum-it@yandex.ru",address:"452771, Республика Башкортостан, Туймазинский район, д. Исмаилово, ул. Строительная, д. 8",maxChatId:""};
export async function getSettings(){const rows=await prisma.setting.findMany();return {...DEFAULT_SETTINGS,...Object.fromEntries(rows.map(x=>[x.key,x.value]))}}
export async function saveSettings(data:Record<string,string>){await prisma.$transaction(Object.entries(data).map(([key,value])=>prisma.setting.upsert({where:{key},create:{key,value},update:{value}})))}
