import type {MetadataRoute} from "next";
export default function sitemap():MetadataRoute.Sitemap{const base=process.env.NEXT_PUBLIC_SITE_URL||"https://posterum-it.ru";return ["","/1c","/servers","/infrastructure","/contacts","/privacy"].map(path=>({url:base+path,lastModified:new Date(),changeFrequency:path===""?"weekly":"monthly",priority:path===""?1:.8}))}
