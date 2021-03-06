# $FreeBSD$

PORTNAME=	wayfire
DISTVERSION=	0.4.0
PORTREVISION=	1
CATEGORIES=	x11-wm

PATCH_SITES=	https://github.com/${GH_ACCOUNT}/${GH_PROJECT}/commit/
PATCHFILES+=	e5b6f1245709.patch:-p1 # https://github.com/WayfireWM/wayfire/pull/472

MAINTAINER=	jbeich@FreeBSD.org
COMMENT=	3D Wayland compositor

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE

BUILD_DEPENDS=	evdev-proto>0:devel/evdev-proto \
		wf-config>=0.4.0<0.5.0:devel/wf-config \
		${LOCALBASE}/include/xf86drmMode.h:graphics/libdrm \
		wayland-protocols>=1.12:graphics/wayland-protocols \
		glm>=0.9.8:math/glm \
		wlroots>=0.9.0<0.11.0:x11-toolkits/wlroots
LIB_DEPENDS=	libinotify.so:devel/libinotify \
		libwf-config.so:devel/wf-config \
		libpng.so:graphics/png \
		libwayland-server.so:graphics/wayland \
		libwlroots.so:x11-toolkits/wlroots \
		libinput.so:x11/libinput \
		libxkbcommon.so:x11/libxkbcommon

USES=		compiler:c++17-lang gl gnome jpeg meson pkgconfig xorg
USE_GITHUB=	yes
USE_GL=		egl glesv2
USE_GNOME=	cairo
USE_XORG=	pixman
GH_ACCOUNT=	WayfireWM

OPTIONS_DEFINE=	SUID
OPTIONS_DEFAULT=SUID

SUID_DESC=		setuid bit on "${PORTNAME}" binary (required for DRM session)
SUID_PLIST_SUB=		MAYBE_SUID="@(,,4755) "
SUID_PLIST_SUB_OFF=	MAYBE_SUID=""

.include <bsd.port.mk>
